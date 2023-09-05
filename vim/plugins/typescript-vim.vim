" leafgarland/typescript-vim {{{
call dein#add('leafgarland/typescript-vim', {
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'on_ft' : [
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })
" }}}


