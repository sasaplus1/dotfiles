scriptencoding utf-8

function! s:hook_source() abort
" hook_source {{{
  if dein#tap('vim-gruvbox8')
    if !dein#is_sourced('vim-gruvbox8')
      call dein#source('vim-gruvbox8')
    endif
    let g:lightline = { 'colorscheme' : 'gruvbox8' }
    set background=dark
    colorscheme gruvbox8
    if has('nvim-0.11')
      " workaround
      " https://github.com/nvim-lualine/lualine.nvim/issues/1312
      " https://github.com/neovim/neovim/commit/e049c6e4c08a141c94218672e770f86f91c27a11
      highlight StatusLine gui=NONE
      highlight StatusLineNC gui=NONE
    endif
  endif
" }}}
endfunction

" NOTE: ColorSchemeイベントは初回起動時に必要
call dein#add('itchyny/lightline.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_event' : ['ColorScheme', 'VimEnter']
      \ })

" vim:ft=vim:fdm=marker:fen:
