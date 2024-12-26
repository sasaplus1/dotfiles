scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  nnoremap <silent> <leader>r :<C-u>QuickRun<CR>
" }}}
endfunction

call dein#add('thinca/vim-quickrun', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_cmd' : ['QuickRun'],
      \ 'on_map' : ['<Leader>r', '<Plug>(quick'],
      \ })

" vim:ft=vim:fdm=marker:fen:
