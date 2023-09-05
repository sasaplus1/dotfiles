scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('thinca/vim-qfreplace', {
      \ 'lazy' : 1,
      \ 'on_cmd' : 'Qfreplace',
      \ })

" vim:ft=vim:fdm=marker:fen:
