# execute source if macOS
if [ "$TERM" != 'dumb' ] && [[ "$OSTYPE" =~ ^darwin ]]
then
  source "$HOME/.bashrc" 2>/dev/null
fi
