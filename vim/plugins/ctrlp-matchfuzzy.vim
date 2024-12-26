scriptencoding utf-8

" use fzf
finish

call dein#add('mattn/ctrlp-matchfuzzy', {
      \ 'if' : 'exists("*matchfuzzy")',
      \ 'lazy' : 1,
      \ 'on_source' : 'ctrlp.vim',
      \ })

" vim:ft=vim:fdm=marker:fen:
