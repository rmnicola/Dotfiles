return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>P", group = "Presenterm" },
      },
    },
  },
  {
    "Piotr1215/presenterm.nvim",
    build = false,
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {},
    keys = {
      -- Standard Plugin Mappings
      { "[s",         "<cmd>Presenterm prev<cr>",            desc = "Prev slide" },
      { "]s",         "<cmd>Presenterm next<cr>",            desc = "Next slide" },
      { "<leader>Pn", "<cmd>Presenterm new<cr>",             desc = "New slide" },
      { "<leader>Ps", "<cmd>Presenterm split<cr>",           desc = "Split slide" },
      { "<leader>Pd", "<cmd>Presenterm delete<cr>",          desc = "Delete slide" },
      { "<leader>Py", "<cmd>Presenterm yank<cr>",            desc = "Yank slide" },
      { "<leader>Pv", "<cmd>Presenterm select<cr>",          desc = "Select slide" },
      { "<leader>Pk", "<cmd>Presenterm move-up<cr>",         desc = "Move slide up" },
      { "<leader>Pj", "<cmd>Presenterm move-down<cr>",       desc = "Move slide down" },
      { "<leader>PR", "<cmd>Presenterm reorder<cr>",         desc = "Reorder slides" },
      { "<leader>Pl", "<cmd>Presenterm list<cr>",            desc = "List slides" },
      { "<leader>PL", "<cmd>Presenterm layout<cr>",          desc = "Select layout" },
      { "<leader>Pp", "<cmd>Presenterm partial include<cr>", desc = "Include partial" },
      { "<C-e>",      "<cmd>Presenterm exec toggle<cr>",     desc = "Toggle exec" },
      { "<leader>Pr", "<cmd>Presenterm exec run<cr>",        desc = "Run code block" },
      {
        "<leader>PP",
        function()
          local file = vim.fn.expand("%:p")
          -- [fullscreen] creates a specific window rule just for this new window
          local cmd = string.format("hyprctl dispatch exec '[fullscreen] ghostty --font-size=22 -e presenterm %s'", file)
          vim.fn.jobstart(cmd, { detach = true })
        end,
        desc = "Start presentation"
      },
    },
  },
}
