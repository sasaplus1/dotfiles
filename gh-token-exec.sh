#!/usr/bin/env bash
#
# Get a GitHub App user access token through Device Flow, run a command with
# the token in its environment, and revoke the token as soon as the command
# exits.
#
# The token is never written to disk, never printed, and never passed as a
# command line argument, so it cannot be picked up from `ps` output, a shell
# history, or a coding agent transcript.
#
# Requirements: bash, curl, sed, tr, head. No JSON parser is needed: Device
# Flow answers in application/x-www-form-urlencoded, and the revoke endpoint
# only takes a request body.
#
# Usage:
#   gh-token-exec.sh [-c CLIENT_ID] [-e VAR] -- COMMAND [ARG...]
#
# Example:
#   gh-token-exec.sh -e GH_TOKEN -- gh release download -R owner/private-repo

set -euo pipefail

# tracing would print the token, so refuse to run traced even when the caller
# asked for it with `bash -x`
set +xv

readonly device_code_url='https://github.com/login/device/code'
readonly access_token_url='https://github.com/login/oauth/access_token'
readonly revoke_url='https://api.github.com/credentials/revoke'
readonly grant_type='urn:ietf:params:oauth:grant-type:device_code'
readonly api_version='2022-11-28'

# BASH_SOURCE is empty when the script is piped into bash, so fall back to $0
program_name="${BASH_SOURCE[0]:-$0}"
program_name="${program_name##*/}"
readonly program_name

client_id="${GH_CLIENT_ID:-}"
env_names=''
access_token=''
refresh_token=''

#-------------------------------------------------------------------------------

usage() {
  cat <<EOS
Usage: $program_name [-c CLIENT_ID] [-e VAR] -- COMMAND [ARG...]

Get a GitHub App user access token through Device Flow, run COMMAND with the
token in its environment, and revoke the token when COMMAND exits.

Options:
  -c CLIENT_ID  GitHub App Client ID (default: \$GH_CLIENT_ID)
  -e VAR        environment variable to receive the token, repeatable
                (default: GITHUB_TOKEN)
  -h            show this help
EOS
}

abort() {
  echo "$program_name: $1" >&2
  exit 1
}

require_commands() {
  local command_name

  for command_name in curl sed tr head
  do
    command -v "$command_name" >/dev/null 2>&1 ||
      abort "$command_name is required but not found"
  done
}

# decode an application/x-www-form-urlencoded value
urldecode() {
  printf '%b' "$(printf '%s' "$1" | sed 's/+/ /g; s/%/\\x/g')"
}

# read a single field out of an application/x-www-form-urlencoded body
# $1: body, $2: field name
form_value() {
  printf '%s' "$1" | tr '&' '\n' | sed -n "s/^$2=//p" | head -n 1
}

# skip GitHub's account picker when the browser is already signed in
#
# The query parameter is undocumented, so a future GitHub change may simply
# ignore it. That only brings the picker back; the device flow itself is
# unaffected either way.
add_skip_account_picker() {
  case "$1" in
    *\?*) printf '%s&skip_account_picker=true' "$1" ;;
    *) printf '%s?skip_account_picker=true' "$1" ;;
  esac
}

# refuse to hand anything but a GitHub https URL to the browser opener, so a
# tampered verification_uri cannot turn this into an arbitrary open
is_github_https_uri() {
  case "$1" in
    https://github.com/*) return 0 ;;
    *) return 1 ;;
  esac
}

open_browser() {
  if command -v open >/dev/null 2>&1
  then
    open "$1" >/dev/null 2>&1 || :
  elif command -v xdg-open >/dev/null 2>&1
  then
    xdg-open "$1" >/dev/null 2>&1 || :
  fi
}

# revoke every token this script obtained
#
# The revoke endpoint takes no authentication and no client secret, so the
# tokens themselves are the only thing needed to invalidate them.
revoke_tokens() {
  local credentials=''

  [ -n "$access_token" ] && credentials="\"$access_token\""

  if [ -n "$refresh_token" ]
  then
    [ -n "$credentials" ] && credentials="$credentials,"
    credentials="$credentials\"$refresh_token\""
  fi

  [ -z "$credentials" ] && return 0

  access_token=''
  refresh_token=''

  # the body goes through stdin so that no token reaches the process arguments
  if printf '{"credentials":[%s]}' "$credentials" |
    curl -fsS -X POST \
      -H 'Accept: application/vnd.github+json' \
      -H "X-GitHub-Api-Version: $api_version" \
      --data @- \
      "$revoke_url" >/dev/null
  then
    echo "$program_name: token revoked" >&2
  else
    echo "$program_name: failed to revoke token" >&2
  fi
}

# ask GitHub for a device code and walk the user through the approval
start_device_flow() {
  local response verification_uri user_code

  if ! response="$(curl -fsS -X POST \
    -H 'Accept: application/x-www-form-urlencoded' \
    -d "client_id=$client_id" \
    "$device_code_url")"
  then
    abort 'failed to request a device code, check the client id'
  fi

  device_code="$(form_value "$response" device_code)"

  [ -z "$device_code" ] && abort "$(form_value "$response" error)"

  interval="$(form_value "$response" interval)"
  expires_in="$(form_value "$response" expires_in)"

  [ -z "$interval" ] && interval=5
  [ -z "$expires_in" ] && expires_in=900

  verification_uri="$(urldecode "$(form_value "$response" verification_uri)")"
  user_code="$(form_value "$response" user_code)"

  if ! is_github_https_uri "$verification_uri"
  then
    abort "unexpected verification uri: $verification_uri"
  fi

  verification_uri="$(add_skip_account_picker "$verification_uri")"

  echo "$program_name: open $verification_uri and enter: $user_code" >&2

  open_browser "$verification_uri"
}

# poll GitHub until the user approves the device code
wait_for_approval() {
  local deadline response error

  deadline=$((SECONDS + expires_in))

  while [ "$SECONDS" -lt "$deadline" ]
  do
    sleep "$interval"

    # the device code goes through stdin to keep it out of the process arguments
    if ! response="$(printf 'client_id=%s&device_code=%s&grant_type=%s' \
      "$client_id" "$device_code" "$grant_type" |
      curl -fsS -X POST \
        -H 'Accept: application/x-www-form-urlencoded' \
        --data @- \
        "$access_token_url")"
    then
      # a transient failure should not throw away an approval already in flight
      continue
    fi

    error="$(form_value "$response" error)"

    case "$error" in
      '')
        access_token="$(form_value "$response" access_token)"
        refresh_token="$(form_value "$response" refresh_token)"
        return 0
        ;;
      authorization_pending) ;;
      slow_down) interval=$((interval + 5)) ;;
      *) abort "$error" ;;
    esac
  done

  abort 'device code expired'
}

main() {
  local opt name status

  require_commands

  while getopts 'c:e:h' opt
  do
    case "$opt" in
      c) client_id="$OPTARG" ;;
      e) env_names="$env_names $OPTARG" ;;
      h)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 1
        ;;
    esac
  done

  shift $((OPTIND - 1))

  [ -z "$client_id" ] && abort 'client id is required: -c or $GH_CLIENT_ID'

  if [ $# -eq 0 ]
  then
    usage >&2
    exit 1
  fi

  [ -z "$env_names" ] && env_names='GITHUB_TOKEN'

  # revoke on any exit path, including a failed command and a signal
  trap revoke_tokens EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  start_device_flow
  wait_for_approval

  # exported variables are readable only by this user, unlike process arguments
  for name in $env_names
  do
    export "$name=$access_token"
  done

  status=0
  "$@" || status=$?

  exit "$status"
}

main "$@"
