scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" netrwを読み込まない
let g:loaded_netrw = 1
let g:loaded_netrwFileHandlers = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1

" このタイミングで設定しないと実行された後に消えてしまう
function! s:hook_source() abort
  " ,vfでvfilerを開く
  " TODO: -layout=none以外を指定すると表示が崩れない
  nnoremap <expr> ,vf ':<C-u>VFiler -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
  " ,vFでサイドバー風にvfilerを開く
  nnoremap <expr> ,vF ':<C-u>VFiler -keep -layout=left -width=30 -columns=indent,icon,name -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
endfunction

" NOTE: VFilerの表示が初回のみ崩れる問題について
" 表示が崩れていたのはvim-parenmatchのlazyloadのタイミング設定が悪かった
" coc.nvimをlazyloadするようにしたらまた崩れるようになった
call dein#add('obaland/vfiler.vim', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_map' : [',vf', ',vF'],
      \ 'on_cmd' : ['VFiler'],
      \ })

" vim:ft=vim:fdm=marker:fen:
