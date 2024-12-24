scriptencoding utf-8

if !(has('patch-9.0.0185') || has('nvim')) || !executable('node')
  finish
endif

" coc.nvimでTabのマップをするのでcopilot.vimにマップさせない
let g:copilot_no_tab_map = 1

" マップしていることを伝えないと候補が表示されなくなる
" https://github.com/orgs/community/discussions/8105#discussioncomment-2558925
let g:copilot_assume_mapped = 1

call dein#add('github/copilot.vim', {
      \ 'lazy' : 1,
      \ 'on_event' : ['InsertEnter'],
      \ 'on_map' : ['<Plug>(copilot-'],
      \ })

" vim:ft=vim:fdm=marker:fen:
