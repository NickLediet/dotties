-- Java-specific settings and JDTLS configuration
-- This file is loaded automatically when opening Java files

-- Wrap everything in a function to defer execution
local function setup_jdtls()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    vim.notify("nvim-jdtls not found. Run :Lazy sync to install plugins", vim.log.levels.WARN)
    return
  end

  -- Get Mason registry for tool paths
  local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
  if not mason_registry_ok then
    vim.notify("Mason registry not found. Run :Lazy sync to install plugins", vim.log.levels.WARN)
    return
  end

  -- Ensure Mason registry is refreshed
  if not mason_registry.is_installed "jdtls" then
    vim.notify("jdtls not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
    return
  end

  -- Safely get the jdtls package
  local jdtls_pkg_ok, jdtls_pkg = pcall(mason_registry.get_package, "jdtls")
  if not jdtls_pkg_ok or not jdtls_pkg then
    vim.notify("Could not get jdtls package from Mason registry", vim.log.levels.WARN)
    return
  end

  -- Safely get install path
  local path_ok, jdtls_path = pcall(function()
    return jdtls_pkg:get_install_path()
  end)
  if not path_ok or not jdtls_path then
    vim.notify("Could not get jdtls install path. Mason may still be initializing.", vim.log.levels.WARN)
    return
  end

  -- Find the launcher jar
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher_jar == "" then
    vim.notify("JDTLS launcher jar not found at " .. jdtls_path, vim.log.levels.ERROR)
    return
  end

  -- Determine OS-specific config directory
  local os_config
  if vim.fn.has "mac" == 1 then
    os_config = jdtls_path .. "/config_mac"
  elseif vim.fn.has "unix" == 1 then
    os_config = jdtls_path .. "/config_linux"
  else
    os_config = jdtls_path .. "/config_win"
  end

  -- Lombok support (bundled with Mason's jdtls)
  local lombok_jar = jdtls_path .. "/lombok.jar"
  local lombok_agent = ""
  if vim.fn.filereadable(lombok_jar) == 1 then
    lombok_agent = "-javaagent:" .. lombok_jar
  end

  -- Utility function to find the root directory of a Java project
  local function get_project_root()
    return vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }) or vim.fn.getcwd()
  end

  -- Workspace directory for JDTLS (per-project)
  local project_name = vim.fn.fnamemodify(get_project_root(), ":p:h:t")
  local workspace_dir = vim.fn.stdpath "data" .. "/jdtls-workspace/" .. project_name

  -- Find Java executable
  -- Supports SDKMAN, JAVA_HOME, or system java
  local function get_java_executable()
    -- Check SDKMAN current java
    local sdkman_java = vim.fn.expand "$HOME/.sdkman/candidates/java/current/bin/java"
    if vim.fn.executable(sdkman_java) == 1 then
      return sdkman_java
    end

    -- Check JAVA_HOME
    local java_home = os.getenv "JAVA_HOME"
    if java_home then
      local java_from_home = java_home .. "/bin/java"
      if vim.fn.executable(java_from_home) == 1 then
        return java_from_home
      end
    end

    -- Fallback to system java
    if vim.fn.executable "java" == 1 then
      return "java"
    end

    return nil
  end

  local java_cmd = get_java_executable()
  if not java_cmd then
    vim.notify("No Java executable found. Install Java 17+ via SDKMAN or set JAVA_HOME", vim.log.levels.ERROR)
    return
  end

  -- Debug adapter paths (if installed)
  local bundles = {}

  -- Add java-debug-adapter
  if mason_registry.is_installed "java-debug-adapter" then
    local ok, java_debug_pkg = pcall(mason_registry.get_package, "java-debug-adapter")
    if ok and java_debug_pkg then
      local debug_path_ok, java_debug_path = pcall(function()
        return java_debug_pkg:get_install_path()
      end)
      if debug_path_ok and java_debug_path then
        local debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
        if debug_jar ~= "" then
          table.insert(bundles, debug_jar)
        end
      end
    end
  end

  -- Add java-test
  if mason_registry.is_installed "java-test" then
    local ok, java_test_pkg = pcall(mason_registry.get_package, "java-test")
    if ok and java_test_pkg then
      local test_path_ok, java_test_path = pcall(function()
        return java_test_pkg:get_install_path()
      end)
      if test_path_ok and java_test_path then
        local test_jars = vim.fn.glob(java_test_path .. "/extension/server/*.jar", true, true)
        for _, jar in ipairs(test_jars) do
          if not vim.endswith(jar, "com.microsoft.java.test.runner-jar-with-dependencies.jar") then
            table.insert(bundles, jar)
          end
        end
      end
    end
  end

  -- Build the command to start JDTLS
  local cmd = {
    java_cmd,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "-Xmx2G",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
  }

  -- Add lombok agent if available
  if lombok_agent ~= "" then
    table.insert(cmd, lombok_agent)
  end

  -- Add JVM arg to prevent metadata files in project root
  table.insert(cmd, "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false")

  -- Add jar, config, and data arguments
  vim.list_extend(cmd, {
    "-jar",
    launcher_jar,
    "-configuration",
    os_config,
    "-data",
    workspace_dir,
  })

  -- Java-specific keymaps
  local function java_keymaps(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- JDTLS specific commands
    vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "[J]ava [O]rganize Imports" }))
    vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "[J]ava Extract [V]ariable" }))
    vim.keymap.set("v", "<leader>jv", function()
      jdtls.extract_variable(true)
    end, vim.tbl_extend("force", opts, { desc = "[J]ava Extract [V]ariable" }))
    vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "[J]ava Extract [C]onstant" }))
    vim.keymap.set("v", "<leader>jc", function()
      jdtls.extract_constant(true)
    end, vim.tbl_extend("force", opts, { desc = "[J]ava Extract [C]onstant" }))
    vim.keymap.set("v", "<leader>jm", function()
      jdtls.extract_method(true)
    end, vim.tbl_extend("force", opts, { desc = "[J]ava Extract [M]ethod" }))

    -- Test commands
    vim.keymap.set("n", "<leader>jt", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "[J]ava [T]est Class" }))
    vim.keymap.set("n", "<leader>jn", jdtls.test_nearest_method, vim.tbl_extend("force", opts, { desc = "[J]ava Test [N]earest Method" }))

    -- Update project configuration
    vim.keymap.set("n", "<leader>ju", "<Cmd>JdtUpdateConfig<CR>", vim.tbl_extend("force", opts, { desc = "[J]ava [U]pdate Config" }))

    -- Debug commands
    vim.keymap.set("n", "<leader>jd", function()
      require("jdtls.dap").setup_dap_main_class_configs()
      vim.notify("DAP main class configs updated", vim.log.levels.INFO)
    end, vim.tbl_extend("force", opts, { desc = "[J]ava Setup [D]AP" }))
  end

  -- Callback when JDTLS attaches
  local function on_attach(client, bufnr)
    -- Setup keymaps
    java_keymaps(bufnr)

    -- Setup DAP
    if #bundles > 0 then
      require("jdtls.dap").setup_dap()
      require("jdtls.dap").setup_dap_main_class_configs()
    end

    -- Enable jdtls commands
    require("jdtls.setup").add_commands()

    vim.notify("JDTLS attached to buffer", vim.log.levels.INFO)
  end

  -- Get capabilities from nvchad's lspconfig defaults
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  -- Extended capabilities for JDTLS
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  -- JDTLS configuration
  local config = {
    cmd = cmd,
    root_dir = get_project_root(),
    capabilities = capabilities,
    on_attach = on_attach,

    settings = {
      java = {
        format = {
          enabled = true,
          settings = {
            url = vim.fn.stdpath "config" .. "/java-formatter.xml",
            profile = "GoogleStyle",
          },
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "org.mockito.Answers.*",
          },
          filteredTypes = {
            "com.sun.*",
            "io.micrometer.shaded.*",
            "java.awt.*",
            "jdk.*",
            "sun.*",
          },
          importOrder = {
            "java",
            "javax",
            "com",
            "org",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
        configuration = {
          updateBuildConfiguration = "interactive",
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
      },
    },

    init_options = {
      bundles = bundles,
      extendedClientCapabilities = extendedClientCapabilities,
    },
  }

  -- Start or attach to JDTLS
  jdtls.start_or_attach(config)
end

-- Run setup, catching any errors gracefully
local ok, err = pcall(setup_jdtls)
if not ok then
  vim.notify("JDTLS setup error: " .. tostring(err), vim.log.levels.WARN)
end
