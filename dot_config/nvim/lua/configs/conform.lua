local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    java = { "google-java-format" },
    xml = { "lemminx" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  formatters = {
    ["google-java-format"] = {
      prepend_args = { "--aosp" }, -- Use AOSP style (4-space indent)
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
