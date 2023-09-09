scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('hail2u/vim-css3-syntax', {
      \ 'if' : !has('nvim'),
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : ['css', 'html', 'scss'],
      \ })

" vim:ft=vim:fdm=marker:fen:
