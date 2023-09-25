# Dev Config

## zsh
```zsh
brew install kitty
```

## tmux
```zsh
brew install tmux
```

## lazygit
```zsh
brew install lazygit
```

## neovim
```zsh
brew install neovim
brew install ripgrep
```

## Backup config
```zsh
mv kitty ../kitty.bak && mv tmux ../tmux.bak && mv nvim ../nvim.bak
```

## Clone config repo
```zsh
git init -b main
git remote add origin https://github.com/nigelcss/config.git
git pull origin main --allow-unrelated-histories
```

Add unversioned config files to .gitignore, commit and push.

## Keyboard Shortcuts
Settings->Keyboard->Keyboard Shortcuts->Modifier Keys->Caps Lock = ^ Control

## Setup

### kitty
```zsh
brew install powerlevel10k && echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc && source ~/.zshrc
```

Follow the prompts.

Add the following aliases to ~/.zshrc (replace <session> as you like)
```zsh
alias t="tmux"
alias ta="tmux attach"
alias t-<session>="tmux attach-session -t <session>"
```

### tmux
```zsh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux
```
`C+s r`

`C+s I`

### neovim
```zsh
nvim
```

`Space+l S`
