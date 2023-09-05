scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('github/copilot.vim', {
      \ 'lazy' : 1,
      \ 'if' : (has('patch-9.0.0185') || has('nvim')) && executable('node'),
      \ 'on_event' : ['InsertEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
