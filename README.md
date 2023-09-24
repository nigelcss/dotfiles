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

`git remote add origin https://github.com/nigelcss/config/config.git`

`pull origin master --allow-unrelated-histories`

`git push -u origin master`
