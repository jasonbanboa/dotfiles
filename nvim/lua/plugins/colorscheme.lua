return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nordic").setup({
      on_palette = function(palette) end,
      after_palette = function(palette) end,
      on_highlight = function(highlights, palette) end,
      -- Enable bold keywords.
      bold_keywords = true,
      -- Cursorline options.
      cursorline = {
        bold = true,
        bold_number = true,
        theme = "dark",
        blend = 1,
      },
      -- Visual selection options.
      visual = {
        bold = true,
        bold_number = true,
        theme = "dark",
        blend = 1,
      },
    })
    require("nordic").load()
  end,
}
-- return {
--   "projekt0n/github-nvim-theme",
--   name = "github-theme",
--   lazy = false, -- make sure we load this during startup if it is your main colorscheme
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("github-theme").setup({
--       -- ...
--     })
--
--     vim.cmd("colorscheme github_dark_colorblind")
--   end,
-- }

-- return {
--   "navarasu/onedark.nvim",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("onedark").setup({
--       style = "dark",
--     })
--     require("onedark").load()
--   end,
-- }
