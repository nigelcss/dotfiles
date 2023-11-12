# installation and dotfiles

## kitty

```zsh
brew install kitty
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font
```

## tmux

```zsh
brew install tmux
```

## lazygit

```zsh
brew install lazygit
```

## vifm

```zsh
brew install vifm
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

### zsh

```zsh
brew install powerlevel10k && echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc && source ~/.zshrc
```

Follow the prompts.

Add the following aliases to ~/.zshrc

```zsh
alias dv='XDG_CONFIG_HOME="$HOME/.config/nvim-profiles/diff" XDG_DATA_HOME="$HOME/.local/share/nvim-profiles/diff" XDG_CACHE_HOME="$HOME/.cache/nvim-profiles/diff" nvim -d -c "wincmd l" -c "norm ]c"'

alias t='tmux new -A -s "${PWD:t}"'
alias th="tmux new -A -s $USER"
alias ta="tmux new -A -s"
alias tk="tmux kill-session -t"
alias lg="lazygit"
alias n="nvim ."
```

### tmux

```zsh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
rm -rf .tmux
tmux
```

`C+a r`

`C+a I`

### neovim

```zsh
nvim
```

`Space+l S`

### gitconfig
```
[diff]
  tool = nvim
[difftool "nvim"]
  cmd = "XDG_CONFIG_HOME=\"$HOME/.config/nvim-profiles/diff\" XDG_DATA_HOME=\"$HOME/.local/share/nvim-profiles/diff\" XDG_CACHE_HOME=\"$HOME/.cache/nvim-profiles/diff\" nvim -d -c \"wincmd l\" -c \"norm ]c\" \"$LOCAL\" \"$REMOTE\""
  path = 
[merge]
  tool = nvim3x
[mergetool]
	keepBackup = false
[mergetool "nvim3x"]
	cmd = "XDG_CONFIG_HOME=\"$HOME/.config/nvim-profiles/diff\" XDG_DATA_HOME=\"$HOME/.local/share/nvim-profiles/diff\" XDG_CACHE_HOME=\"$HOME/.cache/nvim-profiles/diff\" nvim -d -c \"wincmd l\" -c \"norm ]c\" \"$LOCAL\" \"$MERGED\" \"$REMOTE\""
[mergetool "nvim4x"]
	cmd = "XDG_CONFIG_HOME=\"$HOME/.config/nvim-profiles/diff\" XDG_DATA_HOME=\"$HOME/.local/share/nvim-profiles/diff\" XDG_CACHE_HOME=\"$HOME/.cache/nvim-profiles/diff\" nvim -d -c \"wincmd l\" -c \"norm ]c\" \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\""
```
