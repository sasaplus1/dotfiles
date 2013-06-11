# shutdown ssh-agent
[ -n "$SSH_AGENT_PID" ] && eval `/usr/bin/ssh-agent -k`

# delete ssh-agent env
rm -f "$HOME/.ssh-agent-info"

# load .bash_logout.local
source "$HOME/.bash_logout.local" 2>/dev/null
