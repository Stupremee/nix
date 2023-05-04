local status_ok, copilot = pcall(require, "copilot")
if not status_ok then
  return
end

copilot.setup({
  panel = {
    enabled = true,
    auto_refresh = true,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-o>",
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.3,
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = "<C-f>",
      accept_word = false,
      accept_line = false,
      next = "<C-Right>",
      prev = "<C-Left>",
      dismiss = "<C-b>",
    },
  },
  filetypes = {
    ["*"] = true,
  },
  copilot_node_command = "node", -- Node.js version must be > 16.x
  server_opts_overrides = {},
})
