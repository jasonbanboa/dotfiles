return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- This enables toggling hidden items
          hide_hidden = false, -- Show hidden files (starts with a dot)
          hide_dotfiles = false, -- Don't hide files starting with a dot
          hide_gitignored = false, -- Don't hide gitignored files
        },
      },
    },
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
  },
}
