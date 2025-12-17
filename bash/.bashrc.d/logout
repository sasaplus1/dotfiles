#!/bin/bash
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  # shutdown ssh-agent
  [ -n "$SSH_AGENT_PID" ] && eval "$(command ssh-agent -k)"

  # delete ssh-agent env
  command rm -f "$HOME/.ssh-agent-info"

  # shellcheck disable=SC1091
  [ -r "$HOME/.bash_logout.local" ] && source "$HOME/.bash_logout.local"
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
