scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('itchyny/lightline.vim', {
      \ 'lazy' : 1,
      \ 'on_event' : ['ColorScheme', 'VimEnter']
      \ })

" vim:ft=vim:fdm=marker:fen:
