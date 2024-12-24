scriptencoding utf-8

if !has('nvim')
  finish
endif

" このファイルの拡張子をvimからluaに変更したもの
let s:config = expand('<sfile>:r') . '.lua'

function! s:hook_source() abort
  " Luaの設定ファイルを読み込む
  execute 'luafile' s:config
  " nvim-treesitterでの折りたたみを使用する
  setglobal foldmethod=expr
  setglobal foldexpr=nvim_treesitter#foldexpr()
  " 折りたたみを無効にする
  setglobal nofoldenable
endfunction

call dein#add('nvim-treesitter/nvim-treesitter', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'hook_done_update' : 'TSUpdate',
      \ 'merged' : 0,
      \ })

" vim:ft=vim:fdm=marker:fen:
