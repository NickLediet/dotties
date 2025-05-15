
## General:

- [ ] migrate [`~/.config/.lil-dotties/{bin,src}`](https://github.com/NickLediet/lil-dotties/tree/main/.config/.lil-dotties) to `./bin` & `./src`
    - Note: make sure to include workspace config files
- [ ] port [`install-npm-globals.sh`](https://github.com/NickLediet/lil-dotties/blob/main/.config/.lil-dotties/install-npm-globals.sh) to a template script for `./.chezmoidata/packages.yaml`
- [ ] Fix nvim config
    - [ ] Port over [`.config/nvim/init.lua`](https://github.com/NickLediet/lil-dotties/blob/main/.config/nvim/init.lua)
    - [ ] Decouple Chadnvim so it is pulled via a setup or onchange hook script
- [ ] Migrate [`~/.config/tmux/tmux.conf`](https://github.com/NickLediet/lil-dotties/blob/main/.config/tmux/tmux.conf)
    - [ ] Update paths to be less macbook specific
    - [ ] Document any steps needs to pull tpm packages
- [ ] Migrate/Port tests from lil dotties (goal is to be able to create a dockerized ci/cd pipeline that validates configs won't break any envs. Might not need a mac one as I do all my daily dev work on it)
- [ ] Port zsh configs
    - [ ] `.p10k.zsh`
    - [ ] `.zshrc`
- [ ] Add Zsh completions for...
    - [ ] NX
    - [ ] Voltaa

## Mac Support:

- [ ] Migrate to sdkman to manage Jvm
- [ ] Add Podman (UI & CLI)
- [ ] Add Lando (Requires a custom install script)
- [ ] Add tpm (Tmux package manager, requires custom install script)

## Zsh improvements:
- ctrl+r w/fzf for nx completions
- faster nx completions
- add dynamic light/dark mode with consisting theming accross appps (intellij, mac os, windows, cursor, vscode, tmux, everything)

## WSL/Linux Support:

- [ ] Create a head & headless version

## Windows Support:
- [ ] Create windows specific version of `./run_onchange_darwin-install-packages.sh.tmpl`


