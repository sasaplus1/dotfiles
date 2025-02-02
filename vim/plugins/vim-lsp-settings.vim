scriptencoding utf-8

" use coc.nvim
finish

if has('nvim')
  finish
endif

function! s:hook_source() abort
" hook_source {{{
  if dein#tap('vim-lsp') && !dein#is_sourced('vim-lsp')
    call dein#source('vim-lsp')
  endif
" }}}
endfunction

call dein#add('mattn/vim-lsp-settings', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ })

" vim:ft=vim:fdm=marker:fen:
