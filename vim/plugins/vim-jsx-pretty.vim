scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('MaxMEllon/vim-jsx-pretty', {
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : ['javascript', 'javascriptreact'],
      \ })

" vim:ft=vim:fdm=marker:fen:
