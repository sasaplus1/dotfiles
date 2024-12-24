scriptencoding utf-8

function! s:hook_source() abort
  " map from https://github.com/rhysd/vim-operator-surround
  map <silent>sa <Plug>(operator-surround-append)
  map <silent>sd <Plug>(operator-surround-delete)
  map <silent>sr <Plug>(operator-surround-replace)
  " nmap <silent>sbd <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
  " nmap <silent>sbr <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)
endfunction

call dein#add('rhysd/vim-operator-surround', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_map' : [
      \   'sa',
      \   'sd',
      \   'sr',
      \   '<Plug>(operator-surround-append)',
      \   '<Plug>(operator-surround-delete)',
      \   '<Plug>(operator-surround-replace)',
      \ ],
      \ 'on_source' : 'vim-operator-user',
      \ })

" vim:ft=vim:fdm=marker:fen:
