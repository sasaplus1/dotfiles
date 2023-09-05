" obaland/vfiler.vim {{{
function! s:hook_add_vfiler_vim() abort
  " netrwを読み込まない
  let g:loaded_netrw = 1
  let g:loaded_netrwFileHandlers = 1
  let g:loaded_netrwPlugin = 1
  let g:loaded_netrwSettings = 1

  " ,vfでvfilerを開く
  nnoremap <expr> ,vf ':<C-u>VFiler -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
  " ,vFでサイドバー風にvfilerを開く
  nnoremap <expr> ,vF ':<C-u>VFiler -keep -layout=left -width=30 -columns=indent,icon,name -show-hidden-files ' . fnameescape(expand('%:p:h')) . '<CR>'
endfunction

call dein#add('obaland/vfiler.vim', {
      \ 'lazy' : 1,
      \ 'hook_add' : function('s:hook_add_vfiler_vim'),
      \ 'if' : has('lua') || has('nvim'),
      \ 'on_cmd' : [
      \   'VFiler',
      \ ],
      \ })
" }}}


