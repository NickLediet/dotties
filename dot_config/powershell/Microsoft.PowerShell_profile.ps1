# PowerShell Profile Configuration
# Managed by chezmoi - https://www.chezmoi.io/
# This file is sourced by PowerShell on startup when placed at:
#   Windows: $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#   Cross-platform: $HOME\.config\powershell\Microsoft.PowerShell_profile.ps1

# ============================================================================
# Oh-My-Posh Prompt Configuration
# ============================================================================

# Theme path - uses the bundled p10k_rainbow theme for consistency with Zsh setup
$OMP_THEME = "$HOME\.config\powershell\themes\p10k_rainbow.omp.json"

# Initialize Oh-My-Posh with the custom theme
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $OMP_THEME) {
        oh-my-posh init pwsh --config $OMP_THEME | Invoke-Expression
    } else {
        # Fallback to built-in powerlevel10k_rainbow theme if custom theme not found
        oh-my-posh init pwsh --config powerlevel10k_rainbow | Invoke-Expression
    }
} else {
    Write-Warning "Oh-My-Posh is not installed. Install it with: winget install JanDeDobbeleer.OhMyPosh"
}

# ============================================================================
# PSReadLine Configuration - Enhanced command line editing
# ============================================================================

if (Get-Module -ListAvailable -Name PSReadLine) {
    # Set vi mode for those who prefer it (uncomment to enable)
    # Set-PSReadLineOption -EditMode Vi

    # History settings
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -MaximumHistoryCount 10000

    # Key bindings for history search
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Ctrl+r for reverse history search (similar to bash/zsh)
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory
}

# ============================================================================
# Terminal Icons - File icons in directory listings
# ============================================================================

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module -Name Terminal-Icons
}

# ============================================================================
# Zoxide - Smarter directory navigation (like z/autojump)
# ============================================================================

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ============================================================================
# FZF - Fuzzy finder integration
# ============================================================================

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ============================================================================
# Useful Aliases
# ============================================================================

# Git shortcuts
Set-Alias -Name g -Value git
function gst { git status }
function gco { git checkout $args }
function gcm { git commit -m $args }
function gp { git push }
function gl { git pull }
function gd { git diff $args }
function ga { git add $args }
function gaa { git add --all }
function gb { git branch $args }
function glog { git log --oneline --graph --decorate -20 }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Better ls alternatives (if eza/exa is installed)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ll { eza -la --icons $args }
    function la { eza -a --icons $args }
    function lt { eza -T --icons $args }
    function l { eza --icons $args }
} elseif (Get-Command exa -ErrorAction SilentlyContinue) {
    function ll { exa -la --icons $args }
    function la { exa -a --icons $args }
    function lt { exa -T --icons $args }
    function l { exa --icons $args }
} else {
    function ll { Get-ChildItem -Force $args }
    function la { Get-ChildItem -Force $args }
}

# Create directory and navigate into it
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# ============================================================================
# Environment Configuration
# ============================================================================

# Add common paths to PATH if they exist
$additionalPaths = @(
    "$HOME\.local\bin",
    "$HOME\bin",
    "$HOME\scoop\shims",
    "$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
)

foreach ($path in $additionalPaths) {
    if (Test-Path $path) {
        $env:PATH = "$path;$env:PATH"
    }
}

# Default editor
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $env:EDITOR = "nvim"
    $env:VISUAL = "nvim"
} elseif (Get-Command vim -ErrorAction SilentlyContinue) {
    $env:EDITOR = "vim"
    $env:VISUAL = "vim"
} elseif (Get-Command code -ErrorAction SilentlyContinue) {
    $env:EDITOR = "code --wait"
    $env:VISUAL = "code --wait"
}

# ============================================================================
# Custom Functions
# ============================================================================

# Quick file search (requires fd or falls back to Get-ChildItem)
function ff {
    param([string]$Pattern)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd $Pattern
    } else {
        Get-ChildItem -Recurse -Filter "*$Pattern*" | Select-Object FullName
    }
}

# Quick grep (requires ripgrep or falls back to Select-String)
function rg {
    param([string]$Pattern, [string]$Path = ".")
    if (Get-Command rg.exe -ErrorAction SilentlyContinue) {
        & rg.exe $Pattern $Path
    } else {
        Get-ChildItem -Recurse -Path $Path -File | Select-String -Pattern $Pattern
    }
}

# Which command (similar to Unix which)
function which {
    param([string]$Command)
    Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

# Reload profile
function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded!" -ForegroundColor Green
}

# ============================================================================
# Startup Message (Optional - comment out if not wanted)
# ============================================================================

# Write-Host "PowerShell $($PSVersionTable.PSVersion) - Profile loaded" -ForegroundColor Cyan
