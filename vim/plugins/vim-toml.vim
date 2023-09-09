scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('cespare/vim-toml', {
      \ 'if' : !has('nvim'),
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : 'toml',
      \ })

" vim:ft=vim:fdm=marker:fen:
