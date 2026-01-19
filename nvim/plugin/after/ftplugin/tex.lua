local wk = require("which-key")
local bufnr = vim.api.nvim_get_current_buf()
wk.add({
  -- Register the group with the LaTeX icon ()
  { "<leader>l", group = "TeX", icon = "", buffer = bufnr },

  -- Ported Mappings from your screenshot
  { "<leader>la", "<cmd>VimtexContextMenu<cr>", desc = "Context Menu", buffer = bufnr },
  { "<leader>lc", "<cmd>VimtexClean<cr>", desc = "Clean Aux", buffer = bufnr },
  { "<leader>lC", "<cmd>VimtexCleanFull<cr>", desc = "Clean Full", buffer = bufnr },
  { "<leader>le", "<cmd>VimtexErrors<cr>", desc = "Show Errors", buffer = bufnr },
  { "<leader>lg", "<cmd>VimtexStatus<cr>", desc = "Status", buffer = bufnr },
  { "<leader>lG", "<cmd>VimtexStatusAll<cr>", desc = "Status All", buffer = bufnr },
  { "<leader>li", "<cmd>VimtexInfo<cr>", desc = "Info", buffer = bufnr },
  { "<leader>lI", "<cmd>VimtexInfoFull<cr>", desc = "Info Full", buffer = bufnr },
  { "<leader>lk", "<cmd>VimtexStop<cr>", desc = "Stop Compile", buffer = bufnr },
  { "<leader>lK", "<cmd>VimtexStopAll<cr>", desc = "Stop All", buffer = bufnr },
  { "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "Compile", buffer = bufnr },
  { "<leader>lL", "<cmd>VimtexCompileSelected<cr>", desc = "Compile Selected", buffer = bufnr },
  { "<leader>lm", "<cmd>VimtexImapsList<cr>", desc = "Imaps List", buffer = bufnr },
  { "<leader>lo", "<cmd>VimtexCompileOutput<cr>", desc = "Compile Output", buffer = bufnr },
  { "<leader>lq", "<cmd>VimtexLog<cr>", desc = "View Log", buffer = bufnr },
  { "<leader>ls", "<cmd>VimtexToggleMain<cr>", desc = "Toggle Main", buffer = bufnr },
  { "<leader>lS", "<cmd>VimtexCompileSS<cr>", desc = "Compile Single Shot", buffer = bufnr },
  { "<leader>lt", "<cmd>VimtexTocOpen<cr>", desc = "Open ToC", buffer = bufnr },
  { "<leader>lT", "<cmd>VimtexTocToggle<cr>", desc = "Toggle ToC", buffer = bufnr },
  { "<leader>lv", "<cmd>VimtexView<cr>", desc = "View PDF", buffer = bufnr },
  { "<leader>lx", "<cmd>VimtexReload<cr>", desc = "Reload", buffer = bufnr },
  { "<leader>lX", "<cmd>VimtexReloadState<cr>", desc = "Reload State", buffer = bufnr },
})
