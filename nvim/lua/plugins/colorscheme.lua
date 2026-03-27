return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nordic").setup({
      bold_keywords = true,
      cursorline = {
        bold = true,
        bold_number = true,
        theme = "dark",
        blend = 1,
      },
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
