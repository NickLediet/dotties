return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- Core
        "vim",
        "lua",
        "vimdoc",
        -- Web
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        -- Java ecosystem
        "java",
        "xml",
        "yaml",
        "toml",
        "groovy", -- for Gradle
        -- Other
        "markdown",
        "markdown_inline",
        "bash",
        "dockerfile",
      },
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },
}
