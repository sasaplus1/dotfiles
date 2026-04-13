vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end
    pcall(function()
      vim.treesitter.language.add(lang)
      vim.treesitter.start(ev.buf, lang)
    end)
  end,
})
