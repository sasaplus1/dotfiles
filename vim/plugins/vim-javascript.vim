scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

" JSDocのハイライトを有効化する
let g:javascript_plugin_jsdoc = 1

call dein#add('pangloss/vim-javascript', {
      \ 'if' : !has('nvim'),
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
