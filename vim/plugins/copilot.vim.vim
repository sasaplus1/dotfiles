scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  " coc.nvimでTabのマップをするのでcopilot.vimにマップさせない
  let g:copilot_no_tab_map = 1

  " マップしていることを伝えないと候補が表示されなくなる
  " https://github.com/orgs/community/discussions/8105#discussioncomment-2558925
  let g:copilot_assume_mapped = 1
" }}}
endfunction

call dein#add('github/copilot.vim', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'if' : '(has("patch-9.0.0185") || has("nvim")) && executable("node")',
      \ 'lazy' : 1,
      \ 'on_event' : ['InsertEnter'],
      \ 'on_map' : ['<Plug>(copilot-'],
      \ })

" vim:ft=vim:fdm=marker:fen:
