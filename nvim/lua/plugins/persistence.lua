return {
  {
    "folke/persistence.nvim",
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      need = 1,
      branch = true,
    },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("dotfiles_persistence_tmux_restore", { clear = true }),
        once = true,
        callback = function()
          local cwd = (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
          local home = vim.env.HOME or ""

          if vim.fn.argc() == 0 and vim.env.TMUX and cwd ~= home then
            require("lazy").load({ plugins = { "persistence.nvim" } })
            require("persistence").load()
          end
        end,
      })
    end,
  },
}
