# NvChad Configuration

This is a custom Neovim configuration built on [NvChad](https://nvchad.com/) v2.5, providing a modern IDE-like experience with full Java development support.

## Features

- **NvChad v2.5** - Modern Neovim configuration framework
- **Java Development** - Full LSP support via nvim-jdtls with debugging capabilities
- **Treesitter** - Syntax highlighting for Java, Lua, TypeScript, and more
- **LSP Support** - HTML, CSS, TypeScript, XML (lemminx), and Java (jdtls)
- **Formatting** - Conform.nvim with Google Java Format, Stylua, and more
- **Debugging** - DAP integration for Java debugging

## Prerequisites

### General Requirements

- **Neovim** >= 0.10.0
- **Git**
- **Node.js** (for some LSP servers)
- A [Nerd Font](https://www.nerdfonts.com/) installed and configured in your terminal

### Java Development Requirements

- **Java 17+** - Required for JDTLS (Java Language Server)
- **Maven** or **Gradle** - For project dependency management

#### Recommended: SDKMAN for Java Management

This configuration is optimized for [SDKMAN](https://sdkman.io/) which allows easy management of multiple JDK versions:

```bash
# Install SDKMAN
curl -s "https://get.sdkman.io" | bash

# Install a JDK (Java 17+)
sdk install java 21.0.2-tem

# Set default JDK
sdk default java 21.0.2-tem
```

The configuration automatically detects SDKMAN-managed Java installations at:
- `~/.sdkman/candidates/java/current/bin/java`

Alternative Java sources are also supported:
- `$JAVA_HOME/bin/java`
- System `java` command

## Installation

After applying your dotfiles with chezmoi, the configuration will be available at `~/.config/nvim/`.

### First-time Setup

1. **Open Neovim** - Lazy.nvim will automatically install plugins
2. **Install Mason tools** - Run `:Mason` and install required tools:
   ```
   :MasonInstall jdtls java-debug-adapter java-test google-java-format lemminx
   ```
   Or let Mason auto-install them (configured in `lua/plugins/java.lua`)

3. **Sync Treesitter parsers** - Run `:TSInstall all` or restart Neovim

## Directory Structure

```
nvim/
├── init.lua                    # Bootstrap lazy.nvim and load NvChad
├── lua/
│   ├── chadrc.lua              # NvChad UI/theme configuration
│   ├── options.lua             # Vim options (tabstop, etc.)
│   ├── mappings.lua            # Custom keymaps
│   ├── autocmds.lua            # Auto commands
│   ├── configs/
│   │   ├── lazy.lua            # Lazy.nvim configuration
│   │   ├── lspconfig.lua       # LSP server configurations
│   │   └── conform.lua         # Formatter configurations
│   └── plugins/
│       ├── init.lua            # Core plugin specs
│       └── java.lua            # Java-specific plugins
└── ftplugin/
    └── java.lua                # Java filetype-specific config (JDTLS)
```

## Java Development

### Features

- **Code Completion** - Intelligent autocomplete with nvim-cmp
- **Go to Definition/References** - Navigate Java code
- **Organize Imports** - Automatic import management
- **Code Actions** - Refactoring support (extract variable/method/constant)
- **Debugging** - Debug Java applications with nvim-dap
- **Test Running** - Run JUnit tests from Neovim
- **Lombok Support** - Full Lombok annotation support

### Java Keymaps

All Java-specific keymaps use `<leader>j` prefix:

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>jo` | Normal | Organize imports |
| `<leader>jv` | Normal/Visual | Extract variable |
| `<leader>jc` | Normal/Visual | Extract constant |
| `<leader>jm` | Visual | Extract method |
| `<leader>jt` | Normal | Run test class |
| `<leader>jn` | Normal | Run nearest test method |
| `<leader>ju` | Normal | Update project configuration |
| `<leader>jd` | Normal | Setup DAP main class configs |

### Project Detection

JDTLS automatically detects project roots by looking for:
- `.git` directory
- `pom.xml` (Maven)
- `build.gradle` (Gradle)
- `mvnw` / `gradlew` wrapper scripts

### Workspace Data

JDTLS workspace data is stored per-project at:
```
~/.local/share/nvim/jdtls-workspace/<project-name>/
```

### Troubleshooting Java LSP

1. **Check if jdtls is installed:**
   ```vim
   :Mason
   ```
   Look for `jdtls` and ensure it shows as installed.

2. **Check LSP status:**
   ```vim
   :LspInfo
   ```

3. **View LSP logs:**
   ```vim
   :lua vim.cmd('e ' .. vim.lsp.get_log_path())
   ```

4. **Verify Java version:**
   ```bash
   java -version  # Should be 17+
   ```

5. **Force JDTLS restart:**
   ```vim
   :JdtRestart
   ```

6. **Update project configuration:**
   ```vim
   :JdtUpdateConfig
   ```

## General Keymaps

### Navigation
| Keymap | Description |
|--------|-------------|
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>e` | Toggle file tree |

### LSP (all languages)
| Keymap | Description |
|--------|-------------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |

### Other
| Keymap | Description |
|--------|-------------|
| `;` | Command mode |
| `jk` | Exit insert mode |
| `<leader>th` | Change theme |

## Formatting

Formatting is handled by [conform.nvim](https://github.com/stevearc/conform.nvim).

| Filetype | Formatter |
|----------|-----------|
| Lua | stylua |
| Java | google-java-format (AOSP style) |
| XML | lemminx |

To format manually:
```vim
:lua require("conform").format()
```

To enable format on save, uncomment the `event = 'BufWritePre'` line in `lua/plugins/init.lua`.

## Customization

### Changing Theme

Edit `lua/chadrc.lua`:
```lua
M.base46 = {
  theme = "catppuccin", -- or any NvChad theme
}
```

### Adding New LSP Servers

1. Install via Mason: `:MasonInstall <server-name>`
2. Add to `lua/configs/lspconfig.lua`:
   ```lua
   local servers = { "html", "cssls", "ts_ls", "lemminx", "your_server" }
   ```

### Adding Treesitter Parsers

Edit `lua/plugins/init.lua` and add to the `ensure_installed` list.

## Resources

- [NvChad Documentation](https://nvchad.com/docs/quickstart/install)
- [nvim-jdtls Wiki](https://github.com/mfussenegger/nvim-jdtls/wiki)
- [SDKMAN Documentation](https://sdkman.io/usage)
- [Lazy.nvim Documentation](https://lazy.folke.io/)
