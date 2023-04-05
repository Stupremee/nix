local status_ok, theme = pcall(require, "catppuccin")
if not status_ok then
  return
end

theme.setup({
  transparent_background = true,
  term_colors = true,
  compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
  integrations = {
    cmp = true,
    native_lsp = {
      enabled = true,
    },
    gitsigns = true,
    nvimtree = true,
    illuminate = true,
    treesitter = true,
    telescope = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = false,
    },
  },
})
