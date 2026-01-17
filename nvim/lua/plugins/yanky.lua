return {
  {
    "gbprod/yanky.nvim",
    opts = {},
    dependencies = { "folke/snacks.nvim" },
    keys = {
      {
        "<leader>P",
        function()
          ---@diagnostic disable-next-line: undefined-field
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
    }
  }
}
