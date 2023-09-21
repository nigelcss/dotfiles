# Dev Config

## kitty
`brew install kitty`

Add the following lines to kitty.conf:

`font_family      Hack Nerd Font\n
bold_font        Hack Nerd Font Bold\n
italic_font      Hack Nerd Font Italic\n
bold_italic_font Hack Nerd Font Bold Italic\n
font_size 12.0\n
map kitty_mod+k no_op\n
map kitty_mod+h no_op\n`

### kitty themes
`git clone --depth 1 https://github.com/dexpota/kitty-themes.git ~/.config/kitty-themes\n`
`ln -s ~/.config/kitty-themes/themes/Neutron.conf ~/.config/kitty/theme.conf\n`

Add this line to your kitty.conf configuration file:
`include ./theme.conf`

## tmux
`brew install tmux`

## lazygit
`brew install lazygit`

