scriptencoding utf-8

call dein#add('github/copilot.vim', {
      \ 'if' : (has('patch-9.0.0185') || has('nvim')) && executable('node'),
      \ })

" vim:ft=vim:fdm=marker:fen:
