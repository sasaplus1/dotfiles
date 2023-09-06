scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" matchparenを読み込まない
let g:loaded_matchparen = 1

let g:parenmatch_highlight = 0

function! s:hook_source_vim_parenmatch() abort
  " parenmatchの強調表示にmatchparenの色を使う
  highlight default link ParenMatch MatchParen
endfunction

call dein#add('itchyny/vim-parenmatch', {
      \ 'hook_source' : function('s:hook_source_vim_parenmatch'),
      \ 'lazy' : 1,
      \ 'on_event' : ['CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI'],
      \ })

" vim:ft=vim:fdm=marker:fen:
