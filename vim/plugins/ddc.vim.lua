local capabilities = require(
  "ddc_source_lsp"
).make_client_capabilities()
require("lspconfig").denols.setup({
  capabilities = capabilities,
})
