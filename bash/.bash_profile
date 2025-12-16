#!/bin/bash
# NOTE: shebang for shellcheck

# shellcheck disable=SC1091
[ -r "$HOME/.bashrc.d/profile" ] && source "$HOME/.bashrc.d/profile"

# shellcheck disable=SC1091
[ -r "$HOME/.bashrc" ] && source "$HOME/.bashrc"

# vim:ft=sh:fdm=marker:fen:
