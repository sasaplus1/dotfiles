" junegunn/vim-easy-align {{{
function! s:hook_post_source_vim_easy_align() abort
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)
  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)
endfunction

call dein#add('junegunn/vim-easy-align', {
      \ 'hook_post_source' : function('s:hook_post_source_vim_easy_align'),
      \ 'on_map' : [
      \   'ga',
      \ ],
      \ })
" }}}


