# gh extensions are installed via programs.gh.extensions in home.nix,
# so they are listed here instead of packages/common.nix.
{ pkgs-unstable, lib }:
[
  pkgs-unstable.gh-dash
  pkgs-unstable.gh-poi
  pkgs-unstable.gh-stack
]
