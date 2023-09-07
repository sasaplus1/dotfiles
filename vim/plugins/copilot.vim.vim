scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" coc.nvimでTabのマップをするのでcopilot.vimにマップさせない
let g:copilot_no_tab_map = 1

" マップしていることを伝えないと候補が表示されなくなる
" https://github.com/orgs/community/discussions/8105#discussioncomment-2558925
let g:copilot_assume_mapped = 1

call dein#add('github/copilot.vim', {
      \ 'lazy' : 1,
      \ 'if' : (has('patch-9.0.0185') || has('nvim')) && executable('node'),
      \ 'on_cmd' : ['<Plug>(copilot-'],
      \ 'on_event' : ['InsertEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
