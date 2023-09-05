" cespare/vim-toml {{{
call dein#add('cespare/vim-toml', {
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'on_ft' : [
      \   'toml',
      \ ],
      \ })
" }}}


