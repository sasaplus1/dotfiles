scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('cespare/vim-toml', {
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : 'toml',
      \ })

" vim:ft=vim:fdm=marker:fen:
