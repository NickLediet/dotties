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

## Platform Support

| Platform | Status |
|----------|--------|
| macOS | ✅ Primary |
| Linux/WSL | 🚧 In progress |
| Windows | 🚧 Planned |

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
