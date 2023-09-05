scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

function! s:hook_add_previm() abort
  " リアルタイムにプレビューする
  let g:previm_enable_realtime = 1
endfunction

call dein#add('previm/previm', {
      \ 'depends' : 'open-browser.vim',
      \ 'hook_add' : function('s:hook_add_previm'),
      \ 'lazy' : 1,
      \ 'on_cmd' : 'PrevimOpen'
      \ })

" vim:ft=vim:fdm=marker:fen:
