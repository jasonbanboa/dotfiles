return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true, -- shows suggestions automatically like VSCode
        keymap = {
          accept = "<Tab>", -- accept full suggestion
          next = "<M-]>", -- next suggestion
          prev = "<M-[>", -- previous suggestion
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false }, -- disable panel, we want inline ghost text
    },
  },
}
