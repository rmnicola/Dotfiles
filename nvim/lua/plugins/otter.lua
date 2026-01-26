return {
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
    config = function()
      -- Automatically activate otter for markdown files
      local otter = require("otter")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "quarto" },
        callback = function()
          otter.activate({ "python" }, true) -- Activate python diagnostics/completion
        end,
      })
    end,
  },
}
