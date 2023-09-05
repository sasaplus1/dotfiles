scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

function! s:hook_source_open_browser_vim() abort
  let g:netrw_nogx = 1
  nmap gx <Plug>(openbrowser-smart-search)
  vmap gx <Plug>(openbrowser-smart-search)
endfunction

call dein#add('tyru/open-browser.vim', {
      \ 'hook_source' : function('s:hook_source_open_browser_vim'),
      \ 'lazy' : 1,
      \ 'on_cmd' : [
      \   'OpenBrowser',
      \   'OpenBrowserSearch',
      \   'OpenBrowserSmartSearch',
      \   '<Plug>(openbrowser-',
      \ ],
      \ 'on_map' : 'gx',
      \ })
" }}}

" vim:ft=vim:fdm=marker:fen:
