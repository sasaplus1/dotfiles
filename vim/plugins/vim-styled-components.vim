scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('styled-components/vim-styled-components', {
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
