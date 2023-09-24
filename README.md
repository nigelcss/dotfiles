# Dev Config

## kitty
`brew install kitty`

## tmux
`brew install tmux`

## lazygit
`brew install lazygit`

`$(brew --prefix)/opt/fzf/install`

## neovim
`brew install neovim`

`brew install ripgrep`

## Backup config
`mv kitty ../kitty.bak && mv tmux ../tmux.bak && mv nvim ../nvim.bak`

## Clone config repo
`git init`

`git remote add origin https://github.com/nigelcss/config.git`

`git pull origin master --allow-unrelated-histories`

`git push -u origin master`

Add unversioned config files to .gitignore, commit and push.

## Keyboard Shortcuts
Settings->Keyboard->Keyboard Shortcuts->Modifier Keys->Caps Lock = ^ Control

## Setup

### tmux
`git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`

`tmux`

`C+s r`

`C+s I`

### neovim
`nvim`

`Space+l S`


