-- Java Development Plugin Configuration
-- Provides full Java LSP support via nvim-jdtls with Mason integration
-- Compatible with SDKMAN-managed JDKs

return {
  -- Mason for installing jdtls and related tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls", -- Java Language Server
        "java-debug-adapter", -- Java Debug Adapter
        "java-test", -- Java Test Runner
        "google-java-format", -- Java formatter
        "lemminx", -- XML LSP (for pom.xml, etc.)
      },
    },
  },

  -- nvim-jdtls for Java Language Server integration
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-dap", -- Debug Adapter Protocol
      "williamboman/mason.nvim",
    },
  },

  -- nvim-dap for debugging support
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      dapui.setup()

      -- Auto-open/close dap-ui
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
