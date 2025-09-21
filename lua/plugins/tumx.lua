return {
	"christoomey/vim-tmux-navigator",
	config = function()
		-- vim.keymap.set("n", "<leader>rr", "<cmd>CellularAutomaton make_it_rain<CR>")
		-- vim.g.tmux_navigator_no_mappings = 1
		vim.keymap.set("n", "<M-n>", "<cmd>TmuxNavigateLeft<CR>")
		vim.keymap.set("n", "<M-e>", "<cmd>TmuxNavigateDown<CR>")
		vim.keymap.set("n", "<M-u>", "<cmd>TmuxNavigateUp<CR>")
		vim.keymap.set("n", "<M-i>", "<cmd>TmuxNavigateRight<CR>")
		vim.keymap.set("n", "<M-p>", "<cmd>TmuxNavigatePrevious<CR>")
	end,
}
