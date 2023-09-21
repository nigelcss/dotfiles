# Dev Config

## kitty
`brew install kitty`

Add the following lines to kitty.conf:

`
font_family      Hack Nerd Font
bold_font        Hack Nerd Font Bold
italic_font      Hack Nerd Font Italic
bold_italic_font Hack Nerd Font Bold Italic
font_size 12.0
map kitty_mod+k no_op
map kitty_mod+h no_op
`

### kitty themes
`git clone --depth 1 https://github.com/dexpota/kitty-themes.git ~/.config/kitty-themes`
`ln -s ~/.config/kitty-themes/themes/Neutron.conf ~/.config/kitty/theme.conf`

Add this line to your kitty.conf configuration file:
`include ./theme.conf`

## tmux
`brew install tmux`

## lazygit
`brew install lazygit`

