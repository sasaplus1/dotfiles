scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('prabirshrestha/vim-lsp', {
      \ 'lazy' : 1
      \ })

" vim:ft=vim:fdm=marker:fen:
