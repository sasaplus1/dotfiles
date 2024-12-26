scriptencoding utf-8

function! GfImport() abort
  let path = expand('<cfile>')

  if path !~# '\v^..?'
    return 0
  endif

  let files = split(glob(path . '.{tsx,ts,d.ts,mjs,cjs,jsx,js,json}'), '\n')

  if empty(files)
    return 0
  endif

  " TODO: tsconfig-pathsやrequire.resolveなどを使ってパスを解決したい
  " TODO: coc-definitionを使う方が良いかもしれない

  return { 'path' : files[0], 'line' : 0, 'col' : 0 }
endfunction

function! s:hook_source() abort
" hook_source {{{
  call gf#user#extend('GfImport', 1000)
" }}}
endfunction

call dein#add('kana/vim-gf-user', {
      \ 'hooks_file' : expand('<sfile>:p'),
      \ 'lazy' : 1,
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \   'javascript.jsx',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ 'on_map' : [
      \   'gf',
      \   'gF',
      \   '<C-w>f',
      \   '<C-w><C-f>',
      \   '<C-w>F',
      \   '<C-w>gf',
      \   '<C-w>gF',
      \   '<Plug>(gf-user-',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
