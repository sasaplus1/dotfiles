scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('vifm/vifm.vim', {
      \ 'lazy' : 1,
      \ 'on_cmd' : ['Vifm', 'VifmCs'],
      \ })

" vim:ft=vim:fdm=marker:fen:
