scriptencoding utf-8

function! s:hook_source() abort
" hook_source {{{
  let g:netrw_nogx = 1

  nmap gx <Plug>(openbrowser-smart-search)
  vmap gx <Plug>(openbrowser-smart-search)
" }}}
endfunction

call dein#add('tyru/open-browser.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_cmd' : ['OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch'],
      \ 'on_map' : ['gx', '<Plug>(openbrowser-'],
      \ })

" vim:ft=vim:fdm=marker:fen:
