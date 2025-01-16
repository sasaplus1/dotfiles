scriptencoding utf-8

" use coc.nvim
finish

call dein#add('prabirshrestha/asyncomplete.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'if' : 0,
      \ 'lazy' : 1,
      \ 'on_event' : ['BufNewFile', 'BufRead', 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI', 'InsertEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
