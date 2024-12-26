scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  " リアルタイムにプレビューする
  let g:previm_enable_realtime = 1
" }}}
endfunction

call dein#add('previm/previm', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_cmd' : 'PrevimOpen',
      \ 'on_source' : 'open-browser.vim',
      \ })

" vim:ft=vim:fdm=marker:fen:
