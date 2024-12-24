scriptencoding utf-8

" リアルタイムにプレビューする
let g:previm_enable_realtime = 1

call dein#add('previm/previm', {
      \ 'lazy' : 1,
      \ 'on_cmd' : 'PrevimOpen',
      \ 'on_source' : 'open-browser.vim',
      \ })

" vim:ft=vim:fdm=marker:fen:
