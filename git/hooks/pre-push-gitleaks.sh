#!/bin/bash

if ! command -v gitleaks >/dev/null 2>&1
then
  printf 'Error: gitleaks is required to push.\n' >&2
  exit 1
fi

z40="0000000000000000000000000000000000000000"

cyan=$'\033[01;36m'
reset=$'\033[0m'
yellow=$'\033[33m'

# git は push 先リモート名を $1、URL を $2 で渡す
remote_name="$1"

while read -r _local_ref local_sha _remote_ref remote_sha
do
  # ブランチ削除の場合はスキップ
  if [ "$local_sha" = "$z40" ]
  then
    continue
  fi

  # 範囲を決定
  if [ "$remote_sha" != "$z40" ] && git cat-file -e "$remote_sha" 2>/dev/null
  then
    # 理想: remote_shaがローカルに存在する
    range="$remote_sha..$local_sha"
  else
    # フォールバック: push先リモートに未到達の全コミットをスキャン
    # 新規ブランチ、remote_sha欠落、force push等で使用
    if [ "$remote_sha" = "$z40" ]
    then
      printf -- '%sInfo: new branch, scanning commits not yet in %s%s\n' "$cyan" "$remote_name" "$reset" >&2
    else
      printf -- '%sWarning: remote SHA not found locally, scanning commits not yet in %s%s\n' "$yellow" "$remote_name" "$reset" >&2
    fi
    # push先が名前付きリモートならそのリモートを、URL直push等なら全リモートを除外対象にする
    if git remote | grep -Fqx -- "$remote_name"
    then
      range="$local_sha --not --remotes=$remote_name"
    else
      range="$local_sha --not --remotes"
    fi
  fi

  gitleaks git --log-opts="$range" --no-banner --verbose || exit 1
done
