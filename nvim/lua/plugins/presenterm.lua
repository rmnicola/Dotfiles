return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        {
          "<leader>p",
          group = "presenterm",
          icon = { icon = "  ", color = "azure" }
        }
      },
    },
  },
  {
    "rmnicola/presenterm.nvim",
    build = false,
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {
      partials = {
        directory = "_partials",
        resolve_relative = true,
      },
    },
    keys = {
      -- Standard Plugin Mappings
      { "[s",         "<cmd>Presenterm prev<cr>",    desc = "Prev slide" },
      { "]s",         "<cmd>Presenterm next<cr>",    desc = "Next slide" },
      { "<leader>pn", "<cmd>Presenterm new<cr>",     desc = "New slide" },
      { "<leader>ps", "<cmd>Presenterm split<cr>",   desc = "Split slide" },
      { "<leader>pd", "<cmd>Presenterm delete<cr>",  desc = "Delete slide" },
      { "<leader>py", "<cmd>Presenterm yank<cr>",    desc = "Yank slide" },
      { "<leader>pv", "<cmd>Presenterm select<cr>",  desc = "Select slide" },
      { "<leader>pk", "<cmd>Presenterm move-up<cr>", desc = "Move slide up" },
      {
        "<leader>pj",
        "<cmd>Presenterm move-down<cr>",
        desc = "Move slide down"
      },
      { "<leader>pR", "<cmd>Presenterm reorder<cr>", desc = "Reorder slides" },
      { "<leader>pl", "<cmd>Presenterm list<cr>",    desc = "List slides" },
      { "<leader>pL", "<cmd>Presenterm layout<cr>",  desc = "Select layout" },
      {
        "<leader>pi",
        "<cmd>Presenterm partial include<cr>",
        desc = "Include partial"
      },
      { "<C-e>", "<cmd>Presenterm exec toggle<cr>", desc = "Toggle exec" },
      {
        "<leader>pr",
        "<cmd>Presenterm exec run<cr>",
        desc = "Run code block"
      },
      {
        "<leader>pP",
        "<cmd>Presenterm preview<cr>",
        desc = "Preview presentation"
      },
      {
        "<leader>pp",
        function()
          local file = vim.fn.expand("%:p")
          local cmd = string.format(
            "hyprctl dispatch exec '[fullscreen] ghostty --font-size=20 -e presenterm %s'",
            file
          )
          vim.fn.jobstart(cmd, { detach = true })
        end,
        desc = "Start presentation"
      },
    },
  },
}
