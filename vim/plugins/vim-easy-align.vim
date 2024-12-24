scriptencoding utf-8

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

call dein#add('junegunn/vim-easy-align', {
      \ 'lazy' : 1,
      \ 'on_map' : '<Plug>(EasyAlign)',
      \ })

" vim:ft=vim:fdm=marker:fen:
