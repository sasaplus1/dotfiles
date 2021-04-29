#!/bin/bash

# execute source if macOS
if [ "$TERM" != 'dumb' ] && [[ "$OSTYPE" =~ ^darwin ]]
then
  # shellcheck disable=SC1091
  source "$HOME/.bashrc" 2>/dev/null
fi
