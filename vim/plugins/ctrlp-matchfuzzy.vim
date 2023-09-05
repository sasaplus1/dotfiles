call dein#add('mattn/ctrlp-matchfuzzy', {
      \ 'if' : exists('?matchfuzzy') || (has('nvim') && exists('*matchfuzzy')),
      \ 'lazy' : 1,
      \ })
