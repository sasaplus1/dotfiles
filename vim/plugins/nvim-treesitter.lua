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
