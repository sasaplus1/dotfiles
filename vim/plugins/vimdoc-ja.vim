scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('vim-jp/vimdoc-ja', {
      \ 'if' : !has('nvim')
      \ })

" vim:ft=vim:fdm=marker:fen:
