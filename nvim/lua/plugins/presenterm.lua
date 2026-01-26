local function start_presentation()
  local file = vim.fn.expand("%:p")
  -- Use quotes to handle paths with spaces
  local cmd = string.format("hyprctl dispatch exec '[fullscreen] ghostty --font-size=20 -e presenterm \"%s\"'", file)
  vim.fn.jobstart(cmd, { detach = true })
end

local function export_pdf()
  local current_file = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()
  local dirname = vim.fn.fnamemodify(cwd, ":t")
  local output_dir = cwd .. "/export"
  local output_file = output_dir .. "/" .. dirname .. ".pdf"

  -- Ensure directory exists
  vim.fn.mkdir(output_dir, "p")
  vim.notify("Exporting PDF...", vim.log.levels.INFO, { title = "Presenterm" })

  local cmd = { "presenterm", "--export-pdf", current_file, "--output", output_file }
  local output_lines = {}

  vim.fn.jobstart(cmd, {
    pty = true, -- Important: fakes a terminal so presenterm doesn't crash
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(output_lines, line) end
        end
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("Saved to exports/" .. dirname .. ".pdf", vim.log.levels.INFO, { title = "Presenterm" })
      else
        local raw_error = table.concat(output_lines, "\n")
        local clean_error = raw_error:gsub("\27%[[0-9;]*m", "") -- Remove color codes
        vim.notify("Export Failed:\n" .. clean_error, vim.log.levels.ERROR, { title = "Presenterm" })
      end
    end,
  })
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>p", group = "presenterm", icon = { icon = " ", color = "azure" } },
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
      { "[s",         "<cmd>Presenterm prev<cr>",            desc = "Prev slide" },
      { "]s",         "<cmd>Presenterm next<cr>",            desc = "Next slide" },
      { "<leader>pn", "<cmd>Presenterm new<cr>",             desc = "New slide" },
      { "<leader>ps", "<cmd>Presenterm split<cr>",           desc = "Split slide" },
      { "<leader>pd", "<cmd>Presenterm delete<cr>",          desc = "Delete slide" },
      { "<leader>py", "<cmd>Presenterm yank<cr>",            desc = "Yank slide" },
      { "<leader>pv", "<cmd>Presenterm select<cr>",          desc = "Select slide" },
      { "<leader>pk", "<cmd>Presenterm move-up<cr>",         desc = "Move slide up" },
      { "<leader>pj", "<cmd>Presenterm move-down<cr>",       desc = "Move slide down" },
      { "<leader>pR", "<cmd>Presenterm reorder<cr>",         desc = "Reorder slides" },
      { "<leader>pl", "<cmd>Presenterm list<cr>",            desc = "List slides" },
      { "<leader>pL", "<cmd>Presenterm layout<cr>",          desc = "Select layout" },
      { "<leader>pi", "<cmd>Presenterm partial include<cr>", desc = "Include partial" },
      { "<C-e>",      "<cmd>Presenterm exec toggle<cr>",     desc = "Toggle exec" },
      { "<leader>pr", "<cmd>Presenterm exec run<cr>",        desc = "Run code block" },
      { "<leader>pP", "<cmd>Presenterm preview<cr>",         desc = "Preview presentation" },

      -- Custom Mappings
      { "<leader>pe", export_pdf,                            desc = "Export as PDF" },
      { "<leader>pp", start_presentation,                    desc = "Start presentation" },
    },
  },
}
