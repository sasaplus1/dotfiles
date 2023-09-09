scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('styled-components/vim-styled-components', {
      \ 'if' : !has('nvim'),
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
