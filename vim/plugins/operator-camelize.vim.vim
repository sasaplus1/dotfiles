" tyru/operator-camelize.vim {{{
function! s:hook_source_operator_camelize() abort
  vmap <silent>c <Plug>(operator-camelize)
  vmap <silent>_ <Plug>(operator-decamelize)
endfunction

call dein#add('tyru/operator-camelize.vim', {
      \ 'depends' : [
      \   'vim-operator-user',
      \ ],
      \ 'hook_source' : function('s:hook_source_operator_camelize'),
      \ 'lazy' : 1,
      \ 'on_cmd' : [
      \   '<Plug>(operator-camelize-',
      \   '<Plug>(operator-decamelize-',
      \ ],
      \ 'on_map' : [
      \   'c',
      \   '_',
      \ ],
      \ })
" }}}


