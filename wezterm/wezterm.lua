-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.color_scheme = "Tokyo Night Moon"

config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.font_size = 14

config.enable_tab_bar = false

config.enable_scroll_bar = false

config.window_padding = {
	left = 3,
	right = 3,
	top = 3,
	bottom = 3,
}

-- and finally, return the configuration to wezterm
return config