scriptencoding utf-8

nnoremap <silent> <leader>r :<C-u>QuickRun<CR>

call dein#add('thinca/vim-quickrun', {
      \ 'lazy' : 1,
      \ 'on_cmd' : ['QuickRun'],
      \ 'on_map' : ['<Leader>r', '<Plug>(quick'],
      \ })

" vim:ft=vim:fdm=marker:fen:
