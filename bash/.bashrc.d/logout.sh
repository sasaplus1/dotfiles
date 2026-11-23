#!/bin/bash
# NOTE: shebang for shellcheck

__main() {
  unset -f __main

  # shellcheck disable=SC1091
  [ -r "$HOME/.bash_logout.local" ] && source "$HOME/.bash_logout.local"
}
__main "$@"

# vim:ft=sh:fdm=marker:fen:
