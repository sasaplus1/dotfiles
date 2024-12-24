scriptencoding utf-8

if has('nvim')
  finish
endif

" NOTE: pluginディレクトリがないのでlazyにする必要はない
call dein#add('styled-components/vim-styled-components')

" vim:ft=vim:fdm=marker:fen:
