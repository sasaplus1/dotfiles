scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('digitaltoad/vim-pug', {
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : 'pug',
      \ })

" vim:ft=vim:fdm=marker:fen:
