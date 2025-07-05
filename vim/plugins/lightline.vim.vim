scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  let g:lightline = { 'colorscheme' : 'gruvbox8' }
" }}}
endfunction

function! s:hook_source() abort
" hook_source {{{
  if has('nvim-0.11')
    " workaround
    " https://github.com/nvim-lualine/lualine.nvim/issues/1312
    " https://github.com/neovim/neovim/commit/e049c6e4c08a141c94218672e770f86f91c27a11
    highlight StatusLine gui=NONE
    highlight StatusLineNC gui=NONE
  endif
" }}}
endfunction

call dein#add('itchyny/lightline.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_event' : ['ColorScheme']
      \ })

" vim:ft=vim:fdm=marker:fen:
