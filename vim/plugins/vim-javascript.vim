scriptencoding utf-8

if has('nvim')
  finish
endif

" JSDocのハイライトを有効化する
let g:javascript_plugin_jsdoc = 1

" NOTE: pluginディレクトリがないのでlazyにする必要はない
call dein#add('pangloss/vim-javascript')

" vim:ft=vim:fdm=marker:fen:
