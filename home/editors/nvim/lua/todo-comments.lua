local status_ok, todo_comments = pcall(require, "todo-comments")
if not status_ok then
	return
end

todo_comments.setup({
	search = {
		command = "rg",
		args = {
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
		},
		pattern = [[\b(KEYWORDS):]], -- ripgrep regex
	},
})
