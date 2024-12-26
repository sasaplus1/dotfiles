scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)
  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)
" }}}
endfunction

call dein#add('junegunn/vim-easy-align', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_map' : '<Plug>(EasyAlign)',
      \ })

" vim:ft=vim:fdm=marker:fen:
