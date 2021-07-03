#!/bin/bash
# NOTE: shebang for shellcheck

# shellcheck disable=SC1091
[ -r "$HOME/.profile" ] && source "$HOME/.profile"

# shellcheck disable=SC1091
[ -r "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# vim:ft=sh:fdm=marker:fen:
