scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  let g:vifm_exec_args = '-c only'
  " netrwを読み込まない
  let g:loaded_netrw = 1
  let g:loaded_netrwFileHandlers = 1
  let g:loaded_netrwPlugin = 1
  let g:loaded_netrwSettings = 1
  " ,vfでVifmを開く
  nnoremap <silent> ,vf :<C-u>execute 'Vifm' fnameescape(expand('%:p:h'))<CR>
" }}}
endfunction

call dein#add('vifm/vifm.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'if' : 'executable("vifm")',
      \ 'lazy' : 1,
      \ 'on_ft' : 'vifm',
      \ 'on_cmd': ['EditVifm', 'Vifm', 'PeditVifm', 'SplitVifm', 'VsplitVifm', 'DiffVifm', 'TabVifm', 'VifmCs'],
      \ })

" vim:ft=vim:fdm=marker:fen:
