return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "build", -- Envia arquivos de saída para ./build
        aux_dir = "build", -- Envia arquivos auxiliares para ./build
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
    end,
    opts = {
      { "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "compile" },
    }
  },
}
