scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" netrwを読み込まない
let g:loaded_netrw = 1
let g:loaded_netrwFileHandlers = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1

" このタイミングで設定しないと一度読んだ後消えてしまう
function! s:hook_source() abort
  " ,vfでvfilerを開く
  nnoremap <expr> ,vf ':<C-u>VFiler -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
  " ,vFでサイドバー風にvfilerを開く
  nnoremap <expr> ,vF ':<C-u>VFiler -keep -layout=left -width=30 -columns=indent,icon,name -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
endfunction

" TODO: lazyの設定がうまくいかない
" TODO: VimあるいはNeovimで起動直後にVFilerを開くと表示が崩れる
" TODO: highlightが破壊されている？読み込みのタイミング？
" NOTE: 調整中
call dein#add('obaland/vfiler.vim', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_map' : [',vf', ',vF'],
      \ 'on_cmd' : ['VFiler'],
      \ })

" vim:ft=vim:fdm=marker:fen:
