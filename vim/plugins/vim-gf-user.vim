" kana/vim-gf-user {{{
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
    let test = resolve(dir . completion)

    if filereadable(test)
      return {
            \ 'path' : test,
            \ 'line' : 0,
            \ 'col' : 0,
            \ }
    endif
  endfor

  return 0
endfunction

function! s:hook_post_source_vim_gf_user() abort
  call gf#user#extend('GfImport', 1000)
endfunction

call dein#add('kana/vim-gf-user', {
      \ 'lazy' : 1,
      \ 'hook_post_source' : function('s:hook_post_source_vim_gf_user'),
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \   'javascript.jsx',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })
" }}}


