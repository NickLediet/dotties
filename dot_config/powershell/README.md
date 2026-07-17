# PowerShell Configuration

This directory contains PowerShell configuration managed by chezmoi, providing a customized prompt experience similar to the Zsh + Powerlevel10k setup.

## Features

- **Oh-My-Posh prompt** - Colorful, informative prompt matching the Powerlevel10k rainbow theme
- **Git integration** - Branch name, status indicators, and helpful aliases
- **PSReadLine enhancements** - History search, tab completion, prediction
- **Zoxide integration** - Smart directory navigation
- **Terminal Icons** - File icons in directory listings
- **FZF integration** - Fuzzy file and history search

## Requirements

Install the following using `winget` (or chezmoi will install them automatically):

```powershell
winget install JanDeDobbeleer.OhMyPosh
winget install Microsoft.WindowsTerminal
winget install ajeetdsouza.zoxide
winget install junegunn.fzf
```

Install PowerShell modules:

```powershell
Install-Module -Name PSReadLine -Scope CurrentUser -Force
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force
Install-Module -Name PSFzf -Scope CurrentUser -Force
```

### Nerd Font

For the icons and symbols to display correctly, install a Nerd Font:

```powershell
winget install NerdFonts.UbuntuMono
```

Then configure Windows Terminal to use "UbuntuMono Nerd Font" or similar.

## File Structure

```
dot_config/powershell/
├── Microsoft.PowerShell_profile.ps1  # Main profile (sourced on startup)
├── themes/
│   └── p10k_rainbow.omp.json         # Oh-My-Posh theme
└── README.md                          # This file
```

## Chezmoi Mapping

After `chezmoi apply`, these files will be placed at:

- `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
- `~/.config/powershell/themes/p10k_rainbow.omp.json`

## Linking to PowerShell

PowerShell looks for profiles at `$PROFILE`. To use this config, either:

**Option 1: Symlink (Recommended)**
```powershell
$profileDir = Split-Path $PROFILE -Parent
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$HOME\.config\powershell\Microsoft.PowerShell_profile.ps1" -Force
```

**Option 2: Source from default profile**
Add this to your `$PROFILE`:
```powershell
. "$HOME\.config\powershell\Microsoft.PowerShell_profile.ps1"
```

## Customization

### Change Theme

Edit `themes/p10k_rainbow.omp.json` or switch to a built-in theme:

```powershell
# In Microsoft.PowerShell_profile.ps1, change:
$OMP_THEME = "$HOME\.config\powershell\themes\p10k_rainbow.omp.json"
# To use a built-in theme:
# oh-my-posh init pwsh --config paradox | Invoke-Expression
```

### Theme Preview

Preview Oh-My-Posh themes:

```powershell
Get-PoshThemes
```

## Aliases Included

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `gst` | `git status` |
| `gco` | `git checkout` |
| `gcm` | `git commit -m` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `ll` | `eza -la --icons` (or `Get-ChildItem -Force`) |
| `..` | `cd ..` |
| `mkcd` | Create directory and cd into it |
