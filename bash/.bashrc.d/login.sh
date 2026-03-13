#!/bin/bash
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  # shellcheck disable=SC1091
  [ -r "$HOME/.bashrc.d/profile.sh" ] && source "$HOME/.bashrc.d/profile.sh"

  # shellcheck disable=SC1091
  [ -r "$HOME/.bashrc.d/interactive.sh" ] && source "$HOME/.bashrc.d/interactive.sh"
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
