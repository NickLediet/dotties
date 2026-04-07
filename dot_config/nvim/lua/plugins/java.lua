-- Java Development Plugin Configuration
-- Provides full Java LSP support via nvim-jdtls
-- Compatible with SDKMAN-managed JDKs
--
-- JDTLS Installation:
--   Option 1 (Recommended): Manual install
--     mkdir -p ~/.local/share/jdtls && cd ~/.local/share/jdtls
--     curl -L -o jdtls.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
--     tar -xzf jdtls.tar.gz && rm jdtls.tar.gz
--
--   Option 2: Homebrew (macOS)
--     brew install jdtls
--
--   Option 3: Mason (may have issues)
--     :MasonInstall jdtls

return {
  -- nvim-jdtls for Java Language Server integration
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-dap",
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

  -- Mason for optional tooling (formatters, debug adapters)
  -- Note: jdtls is NOT installed via Mason due to reliability issues
  -- Install jdtls manually as described above
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "google-java-format",
        "lemminx",
        -- Optional: uncomment if Mason works for you
        -- "java-debug-adapter",
        -- "java-test",
      },
    },
  },
}
