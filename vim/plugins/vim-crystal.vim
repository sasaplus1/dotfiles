scriptencoding utf-8

" nvim-treesitterにcrystalがないのでNeovimでも使用する

call dein#add('vim-crystal/vim-crystal', {
      \ 'lazy' : 1,
      \ 'on_ft' : ['crystal'],
      \ 'merged' : 0,
      \ })

" vim:ft=vim:fdm=marker:fen:
