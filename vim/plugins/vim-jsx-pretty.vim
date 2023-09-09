scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('MaxMEllon/vim-jsx-pretty', {
      \ 'if' : !has('nvim'),
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
