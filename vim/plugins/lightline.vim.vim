scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

if !has('gui_running')
  set t_Co=256
endif

function! s:hook_source() abort
  if dein#tap('vim-gruvbox8')
    let g:lightline = { 'colorscheme' : 'gruvbox8' }
  endif
endfunction

call dein#add('itchyny/lightline.vim', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_event' : ['ColorScheme', 'VimEnter']
      \ })

" vim:ft=vim:fdm=marker:fen:
