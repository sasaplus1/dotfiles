scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('junegunn/fzf', {
      \ 'build' : './install --bin',
      \ 'lazy' : 1,
      \ 'merged' : 0
      \ })

" vim:ft=vim:fdm=marker:fen:
