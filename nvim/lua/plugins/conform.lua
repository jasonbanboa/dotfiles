return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = {
      timeout_ms = 3000,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      markdown = { "prettier" },
    },
  },
}
