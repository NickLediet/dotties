require("nvchad.configs.lspconfig").defaults()

-- Note: Java (jdtls) is configured separately in ftplugin/java.lua
-- to avoid conflicts with nvim-jdtls plugin
local servers = { "html", "cssls", "ts_ls", "lemminx" }
vim.lsp.enable(servers)

-- Lemminx (XML LSP) configuration for pom.xml and other XML files
vim.lsp.config("lemminx", {
  settings = {
    xml = {
      catalogs = {},
      format = {
        enabled = true,
        splitAttributes = true,
      },
      validation = {
        enabled = true,
        noGrammar = "hint",
        schema = true,
      },
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
