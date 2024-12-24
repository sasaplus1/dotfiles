scriptencoding utf-8

function! s:hook_source() abort
  if dein#tap('vim-gruvbox8')
    if !dein#is_sourced('vim-gruvbox8')
      call dein#source(['vim-gruvbox8'])
    endif
    let g:lightline = { 'colorscheme' : 'gruvbox8' }
    set background=dark
    colorscheme gruvbox8
  endif
endfunction

" NOTE: ColorSchemeイベントは初回起動時に必要
call dein#add('itchyny/lightline.vim', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_event' : ['ColorScheme', 'VimEnter']
      \ })

" vim:ft=vim:fdm=marker:fen:
