scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

function! GfImport() abort
  let path = expand('<cfile>')

  if path !~# '^\.\.\?'
    return 0
  endif

  let completions = [
        \   '.tsx',
        \   '.ts',
        \   '.d.ts',
        \   '.mjs',
        \   '.cjs',
        \   '.jsx',
        \   '.js',
        \   '.json',
        \ ]

  let dir = simplify(expand('%:p:h') . '/' . path)

  for completion in completions
    let file = resolve(dir . completion)

    if filereadable(file)
      return { 'path' : file, 'line' : 0, 'col' : 0 }
    endif
  endfor

  return 0
endfunction

function! s:hook_source() abort
  call gf#user#extend('GfImport', 1000)
endfunction

call dein#add('kana/vim-gf-user', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \   'javascript.jsx',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
