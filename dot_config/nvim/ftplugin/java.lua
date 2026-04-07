-- Java-specific settings and JDTLS configuration
-- This file is loaded automatically when opening Java files

-- Wrap everything in a function to defer execution
local function setup_jdtls()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    vim.notify("nvim-jdtls not found. Run :Lazy sync to install plugins", vim.log.levels.WARN)
    return
  end

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

  -- Find JDTLS installation
  -- Priority: 1) Manual install 2) Mason 3) Homebrew
  local function find_jdtls()
    local jdtls_locations = {
      -- Manual installation in data directory (recommended)
      vim.fn.stdpath "data" .. "/jdtls",
      -- XDG data location
      vim.fn.expand "$HOME/.local/share/jdtls",
      -- Homebrew on macOS
      "/opt/homebrew/opt/jdtls",
      "/usr/local/opt/jdtls",
      -- Linux package managers
      "/usr/share/java/jdtls",
    }

    -- Also check Mason if available
    local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
    if mason_registry_ok then
      local ok, is_installed = pcall(mason_registry.is_installed, "jdtls")
      if ok and is_installed then
        local pkg_ok, jdtls_pkg = pcall(mason_registry.get_package, "jdtls")
        if pkg_ok and jdtls_pkg then
          local path_ok, mason_path = pcall(function()
            return jdtls_pkg:get_install_path()
          end)
          if path_ok and mason_path then
            table.insert(jdtls_locations, 1, mason_path)
          end
        end
      end
    end

    for _, location in ipairs(jdtls_locations) do
      local launcher = vim.fn.glob(location .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      if launcher ~= "" then
        return location, launcher
      end
    end

    return nil, nil
  end

  local jdtls_home, launcher_jar = find_jdtls()

  if not jdtls_home then
    vim.notify(
      "JDTLS not found. Install it manually:\n"
        .. "  mkdir -p ~/.local/share/jdtls\n"
        .. "  cd ~/.local/share/jdtls\n"
        .. "  curl -L -o jdtls.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz\n"
        .. "  tar -xzf jdtls.tar.gz\n"
        .. "  rm jdtls.tar.gz",
      vim.log.levels.WARN
    )
    return
  end

  -- Determine OS-specific config directory
  local os_config
  if vim.fn.has "mac" == 1 then
    os_config = jdtls_home .. "/config_mac"
  elseif vim.fn.has "unix" == 1 then
    os_config = jdtls_home .. "/config_linux"
  else
    os_config = jdtls_home .. "/config_win"
  end

  -- Lombok support
  local lombok_jar = jdtls_home .. "/lombok.jar"
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

  -- Debug adapter bundles (optional)
  local bundles = {}

  -- Look for java-debug-adapter
  local debug_locations = {
    vim.fn.stdpath "data" .. "/java-debug/com.microsoft.java.debug.plugin/target",
    vim.fn.expand "$HOME/.local/share/java-debug",
  }

  -- Check Mason for java-debug-adapter
  local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
  if mason_registry_ok then
    local ok, is_installed = pcall(mason_registry.is_installed, "java-debug-adapter")
    if ok and is_installed then
      local pkg_ok, pkg = pcall(mason_registry.get_package, "java-debug-adapter")
      if pkg_ok and pkg then
        local path_ok, path = pcall(function()
          return pkg:get_install_path()
        end)
        if path_ok and path then
          table.insert(debug_locations, 1, path .. "/extension/server")
        end
      end
    end
  end

  for _, location in ipairs(debug_locations) do
    local debug_jar = vim.fn.glob(location .. "/com.microsoft.java.debug.plugin-*.jar", true)
    if debug_jar ~= "" then
      table.insert(bundles, debug_jar)
      break
    end
  end

  -- Look for java-test
  local test_locations = {
    vim.fn.stdpath "data" .. "/vscode-java-test/server",
    vim.fn.expand "$HOME/.local/share/vscode-java-test/server",
  }

  -- Check Mason for java-test
  if mason_registry_ok then
    local ok, is_installed = pcall(mason_registry.is_installed, "java-test")
    if ok and is_installed then
      local pkg_ok, pkg = pcall(mason_registry.get_package, "java-test")
      if pkg_ok and pkg then
        local path_ok, path = pcall(function()
          return pkg:get_install_path()
        end)
        if path_ok and path then
          table.insert(test_locations, 1, path .. "/extension/server")
        end
      end
    end
  end

  for _, location in ipairs(test_locations) do
    local test_jars = vim.fn.glob(location .. "/*.jar", true, true)
    if #test_jars > 0 then
      for _, jar in ipairs(test_jars) do
        local fname = vim.fn.fnamemodify(jar, ":t")
        if fname ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and fname ~= "jacocoagent.jar" then
          table.insert(bundles, jar)
        end
      end
      break
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
  table.insert(cmd, "-Djava.import.generatesMetadataFilesAtProjectRoot=false")

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

    -- Setup DAP if bundles are available
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

  -- Configure available Java runtimes (SDKMAN support)
  local java_runtimes = {}
  local sdkman_java_dir = vim.fn.expand "$HOME/.sdkman/candidates/java"
  if vim.fn.isdirectory(sdkman_java_dir) == 1 then
    -- Scan for installed Java versions
    local java_versions = vim.fn.glob(sdkman_java_dir .. "/*", false, true)
    for _, java_path in ipairs(java_versions) do
      local version_name = vim.fn.fnamemodify(java_path, ":t")
      if version_name ~= "current" and vim.fn.isdirectory(java_path) == 1 then
        -- Determine the runtime name based on version
        local runtime_name
        if version_name:match "^21" then
          runtime_name = "JavaSE-21"
        elseif version_name:match "^17" then
          runtime_name = "JavaSE-17"
        elseif version_name:match "^11" then
          runtime_name = "JavaSE-11"
        elseif version_name:match "^8" or version_name:match "^1%.8" then
          runtime_name = "JavaSE-1.8"
        end

        if runtime_name then
          table.insert(java_runtimes, {
            name = runtime_name,
            path = java_path,
          })
        end
      end
    end
  end

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
          runtimes = java_runtimes,
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
