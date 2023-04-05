local status_ok, dressing = pcall(require, "dressing")
if not status_ok then
  return
end

dressing.setup({
  input = {
    enabled = true,
  },
  select = {
    enabled = true,
    backend = { "telescope", "fzf_lua", "fzf", "builtin" },
  },
})
