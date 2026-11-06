scriptencoding utf-8

if has('nvim')
  finish
endif

" NOTE: pluginディレクトリがないのでlazyにする必要はない
call dein#add('vifm/vifm.vim', {
      \ 'lazy' : 1,
      \ 'on_ft' : 'vifm',
      \ })

" vim:ft=vim:fdm=marker:fen:
