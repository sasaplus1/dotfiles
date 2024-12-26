scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  vmap <silent>c <Plug>(operator-camelize)
  vmap <silent>_ <Plug>(operator-decamelize)
" }}}
endfunction

call dein#add('tyru/operator-camelize.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_source' : 'vim-operator-user',
      \ 'on_map' : ['c', '_', '<Plug>(operator-'],
      \ })

" vim:ft=vim:fdm=marker:fen:
