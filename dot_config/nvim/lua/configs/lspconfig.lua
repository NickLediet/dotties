-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

local servers = {
  html = {},
  cssls = {},
  -- "lua_lsp",
  -- TypeScript Langauge Server
  -- Note: if you're having issues with this see `$LIL_DOTTIES_PATH/install-npm-globals.sh`
  -- See for config options: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_ls
  ts_ls = {},
  -- See Config: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#graphql
  graphql = {},
  jdtls = function()
    print("JDTLS setup function is running...")
    lspconfig['jdtls'].setup(vim.tbl_extend("force", {
      on_attach = function(client, bufnr)
        print("JDTLS attached to buffer:", bufnr)
        require("nvchad.configs.lspconfig").on_attach(client, bufnr)
      end,
      on_init = function(client)
        print("JDTLS initialized:", client.name)
      end,
      capabilities = nvlsp.capabilities,
    }, require('custom.opts.lsp.jdtls')))
  end,  
  -- jdtls = function()
  --  print("JDTLS setup function is running...")
  --   lspconfig['jdtls'].setup(vim.tbl_extend("force", {
  --     on_attach = nvlsp.on_attach,
  --     on_init = nvlsp.on_init,
  --     capabilities = nvlsp.capabilities,
  --   }, require('custom.opts.lsp.jdtls')))
  -- end,
}

-- lsps with default config
for lsp, config in pairs(servers) do
  if type(config) == 'function' then
    config()
  else
    lspconfig[lsp].setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
    }
  end
end

return lspconfig
-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
