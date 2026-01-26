return {
  {
    "gbprod/yanky.nvim",
    keys = {
      { "<leader>p", false },
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
