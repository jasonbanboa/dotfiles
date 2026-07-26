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
    image = {
      -- view images directly in the buffer (wezterm speaks the kitty graphics protocol)
      -- requires imagemagick (`magick`) and `set -g allow-passthrough on` in tmux
      enabled = true,
      doc = {
        inline = true, -- render images inline in markdown/etc.
        float = true, -- fallback float when inline isn't supported
      },
    },
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
