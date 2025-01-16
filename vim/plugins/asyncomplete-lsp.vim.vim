scriptencoding utf-8

" use coc.nvim
finish

function! s:hook_source() abort
" hook_source {{{
  if !dein#is_sourced('vim-asyncomplete')
    call dein#source('vim-asyncomplete')
  endif
" }}}
endfunction

call dein#add('prabirshrestha/asyncomplete-lsp.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'if' : 0,
      \ 'lazy' : 1,
      \ })

" vim:ft=vim:fdm=marker:fen:
