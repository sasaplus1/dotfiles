scriptencoding utf-8

" use fzf
finish

if !exists('*dein#add')
  finish
endif

call dein#add('mattn/ctrlp-matchfuzzy', {
      \ 'if' : exists('*matchfuzzy'),
      \ })

" vim:ft=vim:fdm=marker:fen:
