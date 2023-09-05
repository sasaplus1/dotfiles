scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('editorconfig/editorconfig-vim', {
      \ 'lazy' : 1,
      \ 'on_event': ['BufNewFile', 'BufRead', 'BufFilePost'],
      \ })

" vim:ft=vim:fdm=marker:fen:
