scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" matchparenを読み込まない
let g:loaded_matchparen = 1

let g:parenmatch_highlight = 0

function! s:hook_source() abort
  " parenmatchの強調表示にmatchparenの色を使う
  highlight default link ParenMatch MatchParen
endfunction

call dein#add('itchyny/vim-parenmatch', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'lazy' : 1,
      \ 'on_event' : ['VimEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
