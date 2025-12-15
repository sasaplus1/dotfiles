#!/bin/bash

hook_name="$1"
shift

git_dir="$(git rev-parse --git-dir 2>/dev/null)"

# 元のフックパスを決定
if [ -n "$GIT_ORIGINAL_HOOKS_PATH" ]
then
  original_hooks_path="$GIT_ORIGINAL_HOOKS_PATH"
elif [ -n "$git_dir" ]
then
  original_hooks_path="$git_dir/hooks"
fi

# 相対パスの解決
if [ -n "$original_hooks_path" ] && [[ "$original_hooks_path" != /* ]]
then
  original_hooks_path="$git_dir/$original_hooks_path"
fi

# 元のフックを実行
if [ -n "$original_hooks_path" ] && [ -x "$original_hooks_path/$hook_name" ]
then
  "$original_hooks_path/$hook_name" "$@" || exit 1
fi
