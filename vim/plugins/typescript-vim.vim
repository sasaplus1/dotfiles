scriptencoding utf-8

if has('nvim')
  finish
endif

call dein#add('leafgarland/typescript-vim', {
      \ 'lazy' : 1,
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : ['typescript', 'typescriptreact'],
      \ })

" vim:ft=vim:fdm=marker:fen:
