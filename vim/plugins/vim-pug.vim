scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('digitaltoad/vim-pug', {
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : 'pug',
      \ })

" vim:ft=vim:fdm=marker:fen:
