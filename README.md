# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), featuring a modern development environment with Neovim (NvChad), tmux, and zsh configurations.

## Quick Start

### Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) installed on your system
- Git configured with SSH access to GitHub

### Installation

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:NickLediet/dotties.git
```

This will:
1. Clone the repository
2. Install SDKMAN (if not already installed)
3. Install Java, Maven, and Spring Boot CLI via SDKMAN
4. Apply configurations to your home directory
5. Set up all dotfiles in their correct locations

## What's Included

### Neovim Configuration

A fully-featured Neovim setup built on [NvChad](https://nvchad.com/) v2.5 with:

- **Java Development** - Full LSP support via nvim-jdtls
  - Code completion, navigation, and refactoring
  - JUnit test runner integration
  - Debugging with nvim-dap
  - Lombok support
  - SDKMAN-managed JDK support
- **Web Development** - HTML, CSS, TypeScript LSP
- **Treesitter** - Modern syntax highlighting
- **Formatting** - Conform.nvim with Google Java Format, Stylua
- **File Navigation** - Telescope, nvim-tree
- **Git Integration** - gitsigns, fugitive

See [nvim/README.md](dot_config/nvim/README.md) for detailed configuration documentation.

### Tmux Configuration

Tmux setup with:
- Custom keybindings
- Theme configuration
- TPM (Tmux Plugin Manager) integration
- Session management
- **Cross-platform clipboard support** - Auto-detects and uses the appropriate clipboard tool

### Herdr Configuration

[Herdr](https://herdr.dev/) - Terminal multiplexer optimized for AI coding agents:
- Session persistence for AI agents (Claude Code, Codex, Cursor, etc.)
- Catppuccin theme with auto light/dark switching
- Vim-style keybindings (ported from tmux config)
- Same prefix key (`ctrl+b`) as tmux for muscle memory
- Agent state notifications and sound alerts
- **Cross-platform clipboard support** - Native clipboard via `copy_on_select` (works on all platforms)

### Zsh Configuration

Zsh setup featuring:
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) prompt
- Custom aliases
- Development tool integrations (Java, Node, etc.)

## Directory Structure

```
dotties/
├── dot_config/
│   ├── nvim/                   # Neovim/NvChad configuration
│   │   ├── init.lua
│   │   ├── lua/
│   │   │   ├── plugins/        # Plugin specifications
│   │   │   └── configs/        # Plugin configurations
│   │   └── ftplugin/           # Filetype-specific configs
│   ├── tmux/                   # Tmux configuration
│   └── dot_lil-dotties/        # Additional shell configs
├── dot_zshrc                   # Zsh configuration
├── dot_p10k.zsh                # Powerlevel10k config
├── .chezmoidata/
│   └── packages.yaml           # Package & SDK definitions
├── run_onchange_before_install-sdkman.sh.tmpl    # SDKMAN installer
├── run_onchange_after_install-sdkman-sdks.sh.tmpl # SDK installer (Java, Maven, etc.)
└── run_onchange_*.sh.tmpl      # Other install scripts
```

## Java Development Setup

This dotfiles repo uses [SDKMAN](https://sdkman.io/) for managing Java, Maven, and other JVM tools. **SDKMAN is installed automatically** when you apply the dotfiles with chezmoi.

### What Gets Installed Automatically

The following are installed via SDKMAN when you run `chezmoi apply`:

| Tool | Versions | Notes |
|------|----------|-------|
| Java (Temurin) | 21 (default), 17, 11 | LTS versions |
| Maven | 3.9.6 | Latest stable |
| Spring Boot CLI | 3.2.5 | For Spring development |

See `.chezmoidata/packages.yaml` to customize versions.

### Managing Java Versions

```bash
# List installed versions
sdk current

# Switch Java version for current session
sdk use java 17.0.11-tem

# Set default Java version
sdk default java 21.0.3-tem

# List all available Java distributions
sdk list java

# Install additional versions
sdk install java 22.0.1-tem
```

### Why SDKMAN over Homebrew?

- **Multiple versions**: Easily manage and switch between JDK versions
- **Consistent paths**: Standard paths that work well with build tools and IDEs
- **Cross-platform**: Works the same on macOS and Linux
- **Build tool integration**: Works seamlessly with Maven, Gradle, etc.
- **No path conflicts**: Avoids the pathing issues that occur with Homebrew-installed JDKs

The Neovim Java configuration automatically detects SDKMAN-managed JDKs at `~/.sdkman/candidates/java/current/`.

## Post-Installation

After applying dotfiles, run these additional setup steps:

### 1. Install Neovim Plugins

Open Neovim - plugins will auto-install via Lazy.nvim.

### 2. Install Mason Tools

In Neovim, run:
```vim
:MasonInstall jdtls java-debug-adapter java-test google-java-format lemminx stylua
```

### 3. Install Treesitter Parsers

In Neovim, run:
```vim
:TSInstall all
```

### 4. Install Tmux Plugins

Press `<prefix> + I` in tmux to install TPM plugins.

### 5. Verify Herdr Installation

```bash
# Check herdr is installed
herdr --version

# Start herdr (or attach to existing session)
herdr

# Detach with ctrl+b q
```

## Platform Support

| Platform | Status |
|----------|--------|
| macOS | ✅ Primary |
| Linux/WSL | ✅ Supported |
| Windows | 🚧 Planned |

### Clipboard Setup by Platform

The tmux configuration automatically detects and uses the appropriate clipboard tool for your platform. Herdr has native clipboard support that works out of the box.

#### macOS
- **tmux**: Uses `pbcopy` (native, no installation needed)
- **herdr**: Native clipboard support via `copy_on_select`

#### Linux (X11)
- **tmux**: Install `xclip` (preferred) or `xsel`:
  ```bash
  # Debian/Ubuntu
  sudo apt install xclip
  # or
  sudo apt install xsel
  
  # Fedora/RHEL
  sudo dnf install xclip
  # or
  sudo dnf install xsel
  
  # Arch
  sudo pacman -S xclip
  # or
  sudo pacman -S xsel
  ```
- **herdr**: Native clipboard support via `copy_on_select`

#### Linux (Wayland)
- **tmux**: Install `wl-clipboard`:
  ```bash
  # Debian/Ubuntu
  sudo apt install wl-clipboard
  
  # Fedora/RHEL
  sudo dnf install wl-clipboard
  
  # Arch
  sudo pacman -S wl-clipboard
  ```
- **herdr**: Native clipboard support via `copy_on_select`

#### WSL (Windows Subsystem for Linux)
- **tmux**: Uses `clip.exe` (native Windows clipboard, no installation needed)
- **herdr**: Native clipboard support via `copy_on_select`

#### Detection Priority
The tmux configuration checks for clipboard tools in this order:
1. WSL (`clip.exe` when `$WSL_DISTRO_NAME` is set)
2. Wayland (`wl-copy` when `$WAYLAND_DISPLAY` is set)
3. X11 (`xclip` when `$DISPLAY` is set)
4. X11 fallback (`xsel` when `$DISPLAY` is set and `xclip` is not available)
5. macOS (`pbcopy`)

## Updating

Pull latest changes and reapply:

```bash
chezmoi update
```

Or manually:

```bash
chezmoi git pull
chezmoi apply
```

### Updating Herdr

```bash
herdr update
```

## Testing This Branch

### On Your Mac

To test this branch on your existing dotfiles setup:

```bash
# 1. Backup your current chezmoi state (optional but recommended)
chezmoi diff > ~/chezmoi-backup.diff

# 2. Change chezmoi source to this branch
cd ~/.local/share/chezmoi
git fetch origin
git checkout cursor/add-herdr-cross-env-7cb8

# 3. Preview what will change
chezmoi diff

# 4. Apply the changes
chezmoi apply

# 5. Verify herdr is installed
herdr --version

# 6. Start herdr
herdr
```

### Restoring Original State

To restore your previous configuration:

```bash
# Option A: Switch back to main branch
cd ~/.local/share/chezmoi
git checkout main
chezmoi apply

# Option B: Full re-initialization from main
chezmoi init --apply git@github.com:NickLediet/dotties.git
```

### Herdr Keybindings Reference

| Keybinding | Action | Tmux Equivalent |
|------------|--------|-----------------|
| `ctrl+b h/j/k/l` | Navigate panes (vim-style) | Same |
| `ctrl+b v` | Split vertical (side-by-side) | `prefix+%` |
| `ctrl+b -` | Split horizontal (stacked) | `prefix+"` |
| `shift+left/right` | Previous/next tab | Same (windows) |
| `ctrl+b c` | New tab | Same (window) |
| `ctrl+b x` | Close pane | Same |
| `ctrl+b z` | Toggle zoom | Same |
| `ctrl+b q` | Detach | `prefix+d` |
| `ctrl+b w` | Workspace picker | Session picker |
| `ctrl+b ?` | Help | Same |
| `ctrl+b shift+r` | Reload config | `prefix+r` |

## Customization

### Local Overrides

Chezmoi supports local customization via:
- `~/.config/chezmoi/chezmoi.toml` - Local configuration
- Template variables in `.chezmoidata/`

### Adding New Configurations

1. Add the file to your home directory
2. Run `chezmoi add <file>` to track it
3. Commit and push changes

## Troubleshooting

### Neovim Issues

See [nvim/README.md](dot_config/nvim/README.md#troubleshooting-java-lsp) for Neovim-specific troubleshooting.

### Chezmoi Issues

```bash
# View what would change
chezmoi diff

# Apply with verbose output
chezmoi apply -v

# Re-initialize if needed
chezmoi init --apply git@github.com:NickLediet/dotties.git
```

## Contributing

This is a personal dotfiles repository, but feel free to:
- Open issues for bugs or suggestions
- Fork for your own customization

## License

MIT License - See [LICENSE](LICENSE) for details.
