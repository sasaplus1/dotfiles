scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" netrwを読み込まない
let g:loaded_netrw = 1
let g:loaded_netrwFileHandlers = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1

" ,vfでvfilerを開く
nnoremap <expr> ,vf ':<C-u>VFiler -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
" ,vFでサイドバー風にvfilerを開く
nnoremap <expr> ,vF ':<C-u>VFiler -keep -layout=left -width=30 -columns=indent,icon,name -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'

" TODO:
" Neovim起動直後にVFilerを開くと表示が崩れる、nvim-treesitterかcoc.nvimで何かある
" 前者のような気がする、Vimでは発生しない
call dein#add('obaland/vfiler.vim', {
      \ 'depends' : has('nvim') ? ['nvim-treesitter'] : [],
      \ 'lazy' : 1,
      \ 'if' : has('lua') || has('nvim'),
      \ 'on_cmd' : ['VFiler'],
      \ })

" vim:ft=vim:fdm=marker:fen:
