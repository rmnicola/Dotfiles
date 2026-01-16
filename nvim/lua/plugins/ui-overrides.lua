return {
  -- 1. Markdown: Keep the plugin installed, but disabled by default.
  --    The toggle (<leader>um) will still work to turn it ON.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = false, -- Start with the "pretty" UI turned off
    },
  },

  -- 2. Smooth Scroll: Ensure it is enabled by default.
  --    The toggle (<leader>uS) will still work to turn it OFF.
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = true }, -- Force smooth scroll on
    },
  },
}
