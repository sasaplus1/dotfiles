" styled-components/vim-styled-components {{{
call dein#add('styled-components/vim-styled-components', {
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })
" }}}


