# lil-dotties aliases
function lil {
	$(cd ~/.lil-src && make $1)
}

alias ls='ls --color'
alias ll='ls -la'
alias vim='nvim'
alias c='clear'
alias reload='exec'
alias workspace="$HOME/.config/.lil-dotties/bin/workspace"

# Docker aliases
function dnuke {
	docker rm $(docker ps -aq)
}

# Kubernetes alias
alias k="kubectl"
alias kc="k config"
alias kgc="kc get-contexts"
alias ksc="kc set-context"
# git aliases
alias gst="git status"
alias gadd="git add"
alias gcm="git commit -m"
alias gp="git push"

# config git alias ports
alias cst="config status"
alias cadd="config add"
alias ccm="config commit -m"

# tmux aliases
alias tls="tmux list-sessions"
alias tks="tmux kill-session -t"
alias tas="tmux attach-session -t"

# java aliases
function mshell {
  jshell --class-path "$(cat class-path.txt)":target/classes
}


# Lil Dotties paths
LIL_DOTTIES_PATH="~/.config/.lil-dotties"
echo "$LIL_DOTTIES_PATH"
alias lil-edit="vim $LIL_DOTTIES_PATH"
alias install-npm-globals="$LIL_DOTTIES_PATH/install-npm-globals.sh"
# don't use unless you really want to
# just use `config push`
# alias cpush="config push"
#

# Load locally hidden aliases for work or machine specific overrides
source ~/.zsh_aliases.local
