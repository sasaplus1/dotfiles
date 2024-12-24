scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('udalov/kotlin-vim', {
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : 'kotlin',
      \ })

" vim:ft=vim:fdm=marker:fen:
