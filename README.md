# Dev Config

## kitty
```sh
brew install kitty
```

## tmux
```bash
brew install tmux
```

## lazygit
```bash
brew install lazygit
```

## neovim
```bash
brew install neovim
brew install ripgrep
```

## Backup config
```zsh
mv kitty ../kitty.bak && mv tmux ../tmux.bak && mv nvim ../nvim.bak
```

## Clone config repo
```
git init
git remote add origin https://github.com/nigelcss/config.git
git pull origin master --allow-unrelated-histories
git push -u origin master
```

Add unversioned config files to .gitignore, commit and push.

## Keyboard Shortcuts
Settings->Keyboard->Keyboard Shortcuts->Modifier Keys->Caps Lock = ^ Control

## Setup

### kitty
```bash
brew install powerlevel10k
echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
source ~/.zshrc
```

Follow the prompts.

Add the following aliases to ~/.zshrc (replace <session> as you like)
```
alias t="tmux"
alias ta="tmux attach"
alias t-<session>="tmux attach-session -t <session>"
```

### tmux
```
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux
```
`C+s r`

`C+s I`

### neovim
```
nvim
```

`Space+l S`
