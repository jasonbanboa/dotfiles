-- lua/plugins/colorscheme.lua
--
-- Active colorscheme picker.
-- To switch themes: comment out the current block and uncomment another.
-- Only ONE block should be active at a time.

return {

  -- Rose Pine -------------------------------------------------------------
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme rose-pine")
    end,
  },

  -- Nordic ----------------------------------------------------------------
  -- {
  --   "AlexvZyl/nordic.nvim",
  --   priority = 1000,
  --   config = function()
  --     require("nordic").setup({
  --       bold_keywords = true,
  --       cursorline = {
  --         bold = true,
  --         bold_number = true,
  --         theme = "dark",
  --         blend = 1,
  --       },
  --       visual = {
  --         bold = true,
  --         bold_number = true,
  --         theme = "dark",
  --         blend = 1,
  --       },
  --     })
  --     require("nordic").load()
  --   end,
  -- },

  -- Catppuccin ------------------------------------------------------------
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd("colorscheme catppuccin")
  --   end,
  -- },

  -- Tokyonight ------------------------------------------------------------
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd("colorscheme tokyonight")
  --   end,
  -- },
}
