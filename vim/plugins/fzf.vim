scriptencoding utf-8

call dein#add('junegunn/fzf', {
      \ 'build' : './install --bin',
      \ 'lazy' : 1,
      \ 'merged' : 0
      \ })
