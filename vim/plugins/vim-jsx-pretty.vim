scriptencoding utf-8

if has('nvim')
  finish
endif

" NOTE: pluginディレクトリがないのでlazyにする必要はない
call dein#add('MaxMEllon/vim-jsx-pretty')

" vim:ft=vim:fdm=marker:fen:
