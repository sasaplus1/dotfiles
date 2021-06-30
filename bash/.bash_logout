#!/bin/bash

# shutdown ssh-agent
[ -n "$SSH_AGENT_PID" ] && eval "$(command ssh-agent -k)"

# delete ssh-agent env
rm -f "$HOME/.ssh-agent-info"

# source .bash_logout.local
# shellcheck disable=SC1091
source "$HOME/.bash_logout.local" 2>/dev/null
