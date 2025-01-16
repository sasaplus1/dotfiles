scriptencoding utf-8

call dein#add('vim-denops/denops.vim', {
      \ 'if' : 'executable("deno")',
      \ 'lazy' : 1,
      \ })

" vim:ft=vim:fdm=marker:fen:
