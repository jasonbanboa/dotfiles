return {
  "folke/snacks.nvim",
  keys = {
    -- disable snacks explorer keys so neo-tree owns these (see neo-tree.lua)
    { "<leader>e", false },
    { "<leader>E", false },
    { "<leader>fe", false },
    { "<leader>fE", false },
  },
  opts = {
    explorer = {
      replace_netrw = false, -- let neo-tree handle `nvim .` instead of snacks explorer
    },
    picker = {
      sources = {
        files = {
          hidden = true,
        },
        explorer = {
          hidden = true,
        },
      },
    },
  },
}
