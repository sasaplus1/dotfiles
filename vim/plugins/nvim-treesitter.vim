scriptencoding utf-8

if !exists('*dein#add') || !has('nvim')
  finish
endif

function! s:hook_source() abort
lua << EOB
  require('nvim-treesitter.configs').setup {
    auto_install = false,
    ensure_installed = 'all',
    highlight = {
      enable = true,
      -- disable = {'vfiler'},
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    sync_install = false,
  }
EOB

  " nvim-treesitterでの折りたたみを使用する
  setglobal foldmethod=expr
  setglobal foldexpr=nvim_treesitter#foldexpr()
  " 折りたたみを無効にする
  setglobal nofoldenable
endfunction

call dein#add('nvim-treesitter/nvim-treesitter', {
      \ 'hook_source' : function('s:hook_source'),
      \ 'hook_done_update' : 'TSUpdate',
      \ 'if' : has('nvim'),
      \ 'lazy' : 1,
      \ 'merged' : 0,
      \ 'on_event' : ['BufRead', 'BufNewFile', 'InsertEnter'],
      \ })

" vim:ft=vim:fdm=marker:fen:
