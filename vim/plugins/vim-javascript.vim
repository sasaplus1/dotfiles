scriptencoding utf-8

if has('nvim')
  finish
endif

function! s:hook_add() abort
" hook_add {{{
  " JSDocのハイライトを有効化する
  let g:javascript_plugin_jsdoc = 1
" }}}
endfunction

" NOTE: pluginディレクトリがないのでlazyにする必要はない
call dein#add('pangloss/vim-javascript', { 'hooks_file' : expand('<script>:p') })

" vim:ft=vim:fdm=marker:fen:
