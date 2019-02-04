# macOS load only .bash_profile
if [[ "$OSTYPE" =~ ^darwin ]] && [ "$TERM" != 'dumb' ]
then
  source "$HOME/.bashrc" 2>/dev/null
fi
