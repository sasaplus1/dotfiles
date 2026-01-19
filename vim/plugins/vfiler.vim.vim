scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  " netrwを読み込まない
  let g:loaded_netrw = 1
  let g:loaded_netrwFileHandlers = 1
  let g:loaded_netrwPlugin = 1
  let g:loaded_netrwSettings = 1
" }}}
endfunction

" このタイミングで設定しないと実行された後に消えてしまう
function! s:hook_source() abort
" hook_source {{{
  " NOTE: 初回実行時なぜか表示が崩れるのでvim-parenmatchを読み込んでおく
  if dein#tap('vim-parenmatch') && !dein#is_sourced('vim-parenmatch')
    call dein#source('vim-parenmatch')
  endif
  " NOTE: 初回実行時なぜか表示が崩れるのでcoc.nvimを読み込んでおく
  if dein#tap('coc.nvim') && !dein#is_sourced('coc.nvim')
    call dein#source('coc.nvim')
  endif

  " ,vfでvfilerを開く
  " TODO: -layout=none以外を指定すると表示が崩れない
  nnoremap <expr> ,vf ':<C-u>VFiler -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
  " ,vpでフローティングウィンドウでvfilerを開く
  nnoremap <expr> ,vp ':<C-u>VFiler -layout=floating -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
  " ,vtでサイドバー風にvfilerを開く
  nnoremap <expr> ,vt ':<C-u>VFiler -keep -toggle -layout=left -width=30 -columns=indent,icon,name -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
" }}}
endfunction

" NOTE: VFilerの表示が初回のみ崩れる問題について
" 表示が崩れていたのはvim-parenmatchのlazyloadのタイミング設定が悪かった
" coc.nvimをlazyloadするようにしたらまた崩れるようになった
call dein#add('obaland/vfiler.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'if' : 'has("lua") || has("nvim")',
      \ 'lazy' : 1,
      \ 'on_cmd' : ['VFiler'],
      \ 'on_map' : [',vf', ',vp', ',vt'],
      \ })

" vim:ft=vim:fdm=marker:fen:
