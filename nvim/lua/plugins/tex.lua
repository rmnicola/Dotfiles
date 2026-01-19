-- lua/plugins/tex.lua
return {
  {
    "lervag/vimtex",
    lazy = false, -- VimTeX often needs to load early for syntax highlighting
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_mappings_enabled = 0
    end,
  },
}
