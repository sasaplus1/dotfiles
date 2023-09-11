scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

function! s:hook_source_operator_camelize() abort
  vmap <silent>c <Plug>(operator-camelize)
  vmap <silent>_ <Plug>(operator-decamelize)
endfunction

call dein#add('tyru/operator-camelize.vim', {
      \ 'depends' : ['vim-operator-user'],
      \ 'hook_source' : function('s:hook_source_operator_camelize'),
      \ 'lazy' : 1,
      \ 'on_map' : ['c', '_', '<Plug>(operator-camelize-', '<Plug>(operator-decamelize-'],
      \ })

" vim:ft=vim:fdm=marker:fen:
