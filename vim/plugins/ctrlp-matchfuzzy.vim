scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

call dein#add('mattn/ctrlp-matchfuzzy', {
      \ 'if' : exists('*matchfuzzy'),
      \ })

" vim:ft=vim:fdm=marker:fen:
