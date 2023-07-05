require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls", "pyre" },
}

-- TODO: Add lsp shortcuts

require("lspconfig").lua_ls.setup {}
