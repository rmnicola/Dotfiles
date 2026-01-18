return {
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "nvim-mini/mini.pairs",      enabled = false },
  -- Disable news alerts
  {
    "LazyVim/LazyVim",
    opts = { news = { lazyvim = false, neovim = false } }
  },
  -- Disable automatic completion popup
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        menu = { auto_show = false },
      }
    }
  },
  -- Start with markdown rendering off
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = false, -- Start with the "pretty" UI turned off
    },
  },
}
