#!/bin/bash

if ! command -v gitleaks >/dev/null 2>&1
then
  printf 'Error: gitleaks is required to commit.\n' >&2
  exit 1
fi

gitleaks git --pre-commit --staged --no-banner --verbose
