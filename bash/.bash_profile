#!/bin/bash

# execute source if macOS
if [ -n "$PS1" ] && [[ "$OSTYPE" =~ ^darwin ]]
then
  # shellcheck disable=SC1091
  source "$HOME/.bashrc" 2>/dev/null
fi
