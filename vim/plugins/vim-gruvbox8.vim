scriptencoding utf-8

" see https://github.com/termstandard/colors

" see :help xterm-true-color
" https://qiita.com/yami_beta/items/ef535d3458addd2e8fbb

function! s:hook_add() abort
" hook_add {{{
  " vscode を起動すると COLORTERM が定義される
  " Terminal.app では COLORTERM は定義されない
  " ただし Terminal.app で tmux を起動した際に空文字で定義している
  let is_support_true_color = $COLORTERM =~# '\vtruecolor|24bit'

  if has('termguicolors') && is_support_true_color
    set termguicolors
  endif

  let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
  let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
" }}}
endfunction

function! s:hook_source() abort
" hook_source {{{
  if !dein#tap('lightline.vim')
    " https://qiita.com/kawaz/items/ee725f6214f91337b42b#colorscheme-%E3%81%AF-vimenter-%E3%81%AB-nested-%E6%8C%87%E5%AE%9A%E3%81%A7%E9%81%85%E5%BB%B6%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B
    autocmd vimrc VimEnter * ++nested set background=dark | colorscheme gruvbox8
  endif
" }}}
endfunction

call dein#add('lifepillar/vim-gruvbox8', {
      \ 'hooks_file' : expand('<sfile>:p'),
      \ 'lazy' : 1,
      \ 'merged' : 0,
      \ 'on_event' : ['ColorScheme', 'VimEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
