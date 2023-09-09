scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" リアルタイムにプレビューする
let g:previm_enable_realtime = 1

call dein#add('previm/previm', {
      \ 'depends' : 'open-browser.vim',
      \ 'lazy' : 1,
      \ 'on_cmd' : 'PrevimOpen'
      \ })

" vim:ft=vim:fdm=marker:fen:
