scriptencoding utf-8

if !has('nvim')
  finish
endif

function! s:hook_source() abort
" hook_source {{{
  " このスクリプトのパスを取得する
  let script = dein#get('nvim-treesitter').hooks_file
  " Luaの設定ファイルを読み込む
  execute 'luafile' fnamemodify(script, ':r') . '.lua'
  " nvim-treesitterでの折りたたみを使用する
  setglobal foldmethod=expr
  setglobal foldexpr=nvim_treesitter#foldexpr()
  " 折りたたみを無効にする
  setglobal nofoldenable
" }}}
endfunction

function! s:hook_done_update() abort
" hook_done_update {{{
  execute 'TSUpdate'
" }}}
endfunction

call dein#add('nvim-treesitter/nvim-treesitter', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'merged' : 0,
      \ })

" vim:ft=vim:fdm=marker:fen:
