scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

let s:colorscheme_name = 'gruvbox8'
let s:colorscheme_repo = 'lifepillar/vim-gruvbox8'

function! s:hook_add_colorscheme() abort
  if dein#tap('lightline.vim')
    let g:lightline = { 'colorscheme' : s:colorscheme_name }
  endif

  " see https://github.com/termstandard/colors

  " see :help xterm-true-color
  " https://qiita.com/yami_beta/items/ef535d3458addd2e8fbb

  " vscode を起動すると COLORTERM が定義される
  " Terminal.app では COLORTERM は定義されない
  " ただし Terminal.app で tmux を起動した際に空文字で定義している
  let isSupportTrueColor = $COLORTERM =~# '\vtruecolor|24bit'

  if has('termguicolors') && isSupportTrueColor
    set termguicolors
  endif

  let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
  let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"

  " https://qiita.com/kawaz/items/ee725f6214f91337b42b#colorscheme-%E3%81%AF-vimenter-%E3%81%AB-nested-%E6%8C%87%E5%AE%9A%E3%81%A7%E9%81%85%E5%BB%B6%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B
  autocmd vimrc VimEnter * ++nested
        \ set background=dark |
        \ execute 'colorscheme' s:colorscheme_name
endfunction

call dein#add(s:colorscheme_repo, {
      \ 'hook_add' : function('s:hook_add_colorscheme'),
      \ 'merged' : 0,
      \ })

" vim:ft=vim:fdm=marker:fen:
