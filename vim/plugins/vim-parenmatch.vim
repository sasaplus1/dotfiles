scriptencoding utf-8

" matchparenを読み込まない
let g:loaded_matchparen = 1

let g:parenmatch_highlight = 0

function! s:hook_source() abort
" hook_source {{{
  " parenmatchの強調表示にmatchparenの色を使う
  highlight default link ParenMatch MatchParen
" }}}
endfunction

call dein#add('itchyny/vim-parenmatch', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_event' : ['VimEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
