scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

function! s:hook_source() abort
  " map from https://github.com/rhysd/vim-operator-surround
  map <silent>sa <Plug>(operator-surround-append)
  map <silent>sd <Plug>(operator-surround-delete)
  map <silent>sr <Plug>(operator-surround-replace)
  nmap <silent>sbd <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
  nmap <silent>sbr <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)
endfunction

call dein#add('rhysd/vim-operator-surround', {
      \ 'depends' : ['vim-operator-user'],
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_cmd' : ['<Plug>(operator-surround-'],
      \ 'on_map' : ['sa', 'sd', 'sr', 'sbd', 'sbr'],
      \ })
" }}}

" vim:ft=vim:fdm=marker:fen:
