scriptencoding utf-8

if !has('nvim')
  finish
endif

" treesitter ハイライトを有効化（Lua で記述）
let s:dir = fnamemodify(resolve(expand('<sfile>')), ':h')
execute 'luafile' simplify(s:dir . '/treesitter.lua')

" treesitter ベースの折りたたみ（デフォルトは無効）
setglobal foldmethod=expr
setglobal foldexpr=v:lua.vim.treesitter.foldexpr()
setglobal nofoldenable

" vim:ft=vim:fdm=marker:fen:
