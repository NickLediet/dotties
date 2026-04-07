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

#### SDKMAN Integration (Automatic)

This dotfiles repository uses [SDKMAN](https://sdkman.io/) for managing Java, Maven, and other JVM tools. **SDKMAN and JDKs are installed automatically** when you apply the dotfiles with chezmoi.

The automatic installation includes:
- **Java** - Temurin 21 (default), 17, and 11
- **Maven** - Latest stable version
- **Spring Boot CLI** - For Spring development

See `.chezmoidata/packages.yaml` for the configured versions.

##### Manual SDKMAN Commands

If you need to manage Java versions manually:

```bash
# List available Java versions
sdk list java

# Install a specific version
sdk install java 21.0.3-tem

# Switch Java version for current session
sdk use java 17.0.11-tem

# Set default Java version
sdk default java 21.0.3-tem

# Check current versions
sdk current
```

##### How Neovim Finds Java

The Neovim Java configuration automatically detects Java in this priority order:
1. `~/.sdkman/candidates/java/current/bin/java` (SDKMAN - preferred)
2. `$JAVA_HOME/bin/java` (environment variable)
3. System `java` command (fallback)

## Installation

After applying your dotfiles with chezmoi, the configuration will be available at `~/.config/nvim/`.

### First-time Setup

1. **Open Neovim** - Lazy.nvim will automatically install plugins (run `:Lazy sync` if needed)

2. **Install JDTLS** (Eclipse Java Language Server) - Choose one method:

   **Option A: Manual Install (Recommended)**
   ```bash
   mkdir -p ~/.local/share/jdtls
   cd ~/.local/share/jdtls
   curl -L -o jdtls.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
   tar -xzf jdtls.tar.gz
   rm jdtls.tar.gz
   ```

   **Option B: Homebrew (macOS)**
   ```bash
   brew install jdtls
   ```

   **Option C: Mason (may have issues)**
   ```vim
   :MasonInstall jdtls
   ```

3. **Install other Mason tools** (optional):
   ```vim
   :MasonInstall google-java-format lemminx
   ```

4. **Sync Treesitter parsers**:
   ```vim
   :TSInstall all
   ```

5. **Restart Neovim** and open a Java file to verify JDTLS starts

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

1. **Check if JDTLS is installed:**
   ```bash
   # Check manual install location
   ls ~/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_*.jar

   # Or check Homebrew
   ls /opt/homebrew/opt/jdtls/libexec/plugins/org.eclipse.equinox.launcher_*.jar
   ```

2. **Check LSP status:**
   ```vim
   :LspInfo
   ```
   You should see `jdtls` listed as attached to the buffer.

3. **View JDTLS logs:**
   ```vim
   :JdtShowLogs
   ```
   Or check the LSP log:
   ```vim
   :lua vim.cmd('e ' .. vim.lsp.get_log_path())
   ```

4. **Verify Java version (must be 17+):**
   ```bash
   java -version
   # Or check SDKMAN
   sdk current java
   ```

5. **"JDTLS not found" error:**
   Install JDTLS manually:
   ```bash
   mkdir -p ~/.local/share/jdtls && cd ~/.local/share/jdtls
   curl -L -o jdtls.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
   tar -xzf jdtls.tar.gz && rm jdtls.tar.gz
   ```

6. **Force JDTLS restart:**
   ```vim
   :JdtRestart
   ```

7. **Wipe corrupted workspace data:**
   ```vim
   :JdtWipeDataAndRestart
   ```
   Or manually delete: `~/.local/share/nvim/jdtls-workspace/<project-name>/`

8. **Update project configuration:**
   ```vim
   :JdtUpdateConfig
   ```

9. **"Java XY language features not available":**
   The config auto-detects SDKMAN-installed JDKs. Check that your project's Java version is installed:
   ```bash
   sdk list java
   sdk install java 17.0.11-tem
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
