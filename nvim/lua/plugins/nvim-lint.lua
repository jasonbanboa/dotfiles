return {
	"mfussenegger/nvim-lint",
	opts = {
		linters_by_ft = {
			javascript = { "eslint" },
			typescript = { "eslint" },
			javascriptreact = { "eslint" },
			typescriptreact = { "eslint" },
			vue = { "eslint" },
		},
		linters = {
			eslint = {
				cmd = function()
					local local_eslint = vim.fn.fnamemodify("node_modules/.bin/eslint", ":p")
					if vim.fn.executable(local_eslint) == 1 then
						return local_eslint
					end
					return "eslint"
				end,
			},
		},
	},
}
