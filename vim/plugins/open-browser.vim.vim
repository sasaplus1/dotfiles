scriptencoding utf-8

let g:netrw_nogx = 1

nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

call dein#add('tyru/open-browser.vim', {
      \ 'lazy' : 1,
      \ 'on_cmd' : ['OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch'],
      \ 'on_map' : ['gx', '<Plug>(openbrowser-'],
      \ })

" vim:ft=vim:fdm=marker:fen:
