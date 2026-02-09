return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- keep LazyVim defaults
    opts.auto_install = true

    -- 🔴 IMPORTANT: force source installs
    local install = require("nvim-treesitter.install")
    install.prefer_git = true
    install.compilers = { "gcc" }
    install.use_git2 = false
  end,
}
