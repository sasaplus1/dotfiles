" itchyny/vim-parenmatch {{{
function! s:hook_source_vim_parenmatch() abort
  let g:parenmatch_highlight = 0

  " parenmatchの強調表示にmatchparenの色を使う
  highlight default link ParenMatch MatchParen
endfunction

call dein#add('itchyny/vim-parenmatch', {
      \ 'hook_source' : function('s:hook_source_vim_parenmatch')
      \ })
" }}}


