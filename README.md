# Dev Config

## kitty
`brew install kitty`

## tmux
`brew install tmux`

`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

## lazygit
`brew install lazygit`

`$(brew --prefix)/opt/fzf/install`

## neovim
`brew install neovim`

`brew install ripgrep`

## Backup config
`mv kitty kitty.bak && mv tmux tmux.bak && mv nvim nvim.bak`

## Clone config
`git init`

`echo * > .gitignore`

`git remote add origin https://github.com/nigelcss/config.git`

`git pull origin master --allow-unrelated-histories`

`git push -u origin master`

## Keyboard Shortcuts
Settings->Keyboard->Keyboard Shortcuts->Modifier Keys->Caps Lock = ^ Control

## Install

### tmux
`git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`

`tmux`

`C+s r`

`C+s I`

### neovim
`nvim`

`Space+l S`


