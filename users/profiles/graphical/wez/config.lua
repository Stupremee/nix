local wezterm = require 'wezterm';
return {
  -- configure font settings
  font = wezterm.font_with_fallback({
    "FiraCode Nerd Font",
    "FiraCode",
    "Noto Sans Nerd Font",
  }),
  font_size = 9.0,

  -- colorscheme
  color_scheme = "nord",

  -- Disable default keybinds because they heavily overlap with sxhkd
  -- and configure new bindings
  disable_default_key_bindings = true,
  leader = {key="a", mods="CTRL", timeout_milliseconds=1000},
  keys = {
    {mods="ALT", key="c", action=wezterm.action{CopyTo="Clipboard"}},
    {mods="ALT", key="v", action=wezterm.action{PasteFrom="Clipboard"}},

    {mods="CTRL", key="-", action="DecreaseFontSize"},
    {mods="CTRL", key="=", action="IncreaseFontSize"},
    {mods="CTRL", key="0", action="ResetFontSize"},

    {mods="CTRL", key="f", action=wezterm.action{Search={CaseSensitiveString=""}}},
    {mods="CTRL", key="x", action="ActivateCopyMode"},
    {mods="CTRL|SHIFT", key="y", action="Copy"},

    {mods="LEADER", key="|", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {mods="LEADER", key="-", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},

    {mods="ALT", key="h", action=wezterm.action{ActivatePaneDirection="Left"}},
    {mods="ALT", key="j", action=wezterm.action{ActivatePaneDirection="Down"}},
    {mods="ALT", key="k", action=wezterm.action{ActivatePaneDirection="Up"}},
    {mods="ALT", key="l", action=wezterm.action{ActivatePaneDirection="Right"}},

    {mods="ALT|SHIFT", key="h", action=wezterm.action{AdjustPaneSize={"Left", 1}}},
    {mods="ALT|SHIFT", key="j", action=wezterm.action{AdjustPaneSize={"Down", 1}}},
    {mods="ALT|SHIFT", key="k", action=wezterm.action{AdjustPaneSize={"Up", 1}}},
    {mods="ALT|SHIFT", key="l", action=wezterm.action{AdjustPaneSize={"Right", 1}}},

    {mods="LEADER", key="l", action="ShowLauncher"},
    {mods="LEADER", key="t", action="ShowTabNavigator"},
    {mods="LEADER", key="w", action=wezterm.action{CloseCurrentTab={confirm=true}}},
    {mods="LEADER", key="c", action=wezterm.action{SpawnTab="DefaultDomain"}},
    {mods="LEADER", key="n", action=wezterm.action{ActivateTabRelative=1}},
    {mods="LEADER", key="p", action=wezterm.action{ActivateTabRelative=-1}},

    {mods="LEADER", key="0", action=wezterm.action{ActivateTab=0}},
    {mods="LEADER", key="1", action=wezterm.action{ActivateTab=1}},
    {mods="LEADER", key="2", action=wezterm.action{ActivateTab=2}},
    {mods="LEADER", key="3", action=wezterm.action{ActivateTab=3}},
    {mods="LEADER", key="4", action=wezterm.action{ActivateTab=4}},
    {mods="LEADER", key="5", action=wezterm.action{ActivateTab=5}},
    {mods="LEADER", key="6", action=wezterm.action{ActivateTab=6}},
    {mods="LEADER", key="7", action=wezterm.action{ActivateTab=7}},
  },

  -- Set colors for tab bar because these are not included in the color scheme
  hide_tab_bar_if_only_one_tab = false,
  colors = {
    tab_bar = {
      background = "#3b4252",

      active_tab = {
        bg_color = "#8fbcbb",
        fg_color = "#3b4252",
        intensity = "Normal",
      },

      inactive_tab = {
        bg_color = "#434c5e",
        fg_color = "#d8dee9",
      },

      inactive_tab_hover = {
        bg_color = "#8fbcbb",
        fg_color = "#3b4252",
        italic = true,
      },
    }
  },

  -- Background styling
  window_background_opacity = 1.0,
  text_background_opacity = 1.0,
  inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 1.0,
  }
}
