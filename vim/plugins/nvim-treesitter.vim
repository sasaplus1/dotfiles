" nvim-treesitter/nvim-treesitter {{{
function! s:setup_nvim_treesitter() abort
lua << EOB
require('nvim-treesitter.configs').setup {
  auto_install = false,
  ensure_installed = 'all',
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  sync_install = false,
}
EOB
endfunction

function! s:hook_add_nvim_treesitter() abort
  autocmd vimrc VimEnter * call <SID>setup_nvim_treesitter()
endfunction

function! s:hook_source_nvim_treesitter() abort
  " nvim-treesitterでの折りたたみを使用する
  setglobal foldmethod=expr
  setglobal foldexpr=nvim_treesitter#foldexpr()
  " 折りたたみを無効にする
  setglobal nofoldenable
endfunction

call dein#add('nvim-treesitter/nvim-treesitter', {
      \ 'hook_add' : function('s:hook_add_nvim_treesitter'),
      \ 'hook_source' : function('s:hook_source_nvim_treesitter'),
      \ 'if' : has('nvim'),
      \ 'merged' : 0,
      \ })
" }}}

