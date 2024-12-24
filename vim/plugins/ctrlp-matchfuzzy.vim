scriptencoding utf-8

" use fzf
finish

if !exists('*matchfuzzy')
  finish
endif

call dein#add('mattn/ctrlp-matchfuzzy', {
      \ 'on_source' : 'ctrlp.vim',
      \ })

" vim:ft=vim:fdm=marker:fen:
