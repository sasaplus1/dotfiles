# load .bash_logout.first
source "$HOME/.bash_logout.first" 2>/dev/null

# shutdown ssh-agent
[ -n "$SSH_AGENT_PID" ] && eval `/usr/bin/ssh-agent -k`

# delete ssh-agent env
rm -f "$HOME/.ssh-agent-info"
