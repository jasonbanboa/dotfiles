-- disable for work
return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      vtsls = function(_, opts)
        local on_attach = opts.on_attach
        opts.on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false

          if on_attach then
            on_attach(client, bufnr)
          end
        end
      end,
    },
  },
}
