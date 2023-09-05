scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

call dein#add('leafgarland/typescript-vim', {
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'on_ft' : [
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
