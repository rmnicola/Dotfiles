local function start_presentation()
  local file = vim.fn.expand("%:p")
  local cmd_fmt = "hyprctl dispatch exec "
      .. "'[fullscreen] kitty -o font_size=20 presenterm %s'"
  local cmd = string.format(cmd_fmt, vim.fn.shellescape(file))
  vim.fn.jobstart(cmd, { detach = true })
end

local function export_pdf()
  local file = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()
  local dirname = vim.fn.fnamemodify(cwd, ":t")
  local output_dir = cwd .. "/export"
  local output_file = output_dir .. "/" .. dirname .. ".pdf"

  vim.fn.mkdir(output_dir, "p")
  vim.notify("Exporting PDF...", vim.log.levels.INFO, {
    title = "Presenterm",
  })

  local output = {}
  local job_cmd = {
    "presenterm",
    "--export-pdf",
    "-x",
    file,
    "--output",
    output_file,
  }

  vim.fn.jobstart(job_cmd, {
    pty = true,
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        output = data
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify(
          "Saved to export/" .. dirname .. ".pdf",
          vim.log.levels.INFO,
          { title = "Presenterm" }
        )
      else
        local err = table.concat(output, "\n"):gsub("\27%[[0-9;]*m", "")
        vim.notify(
          "Export Failed:\n" .. err,
          vim.log.levels.ERROR,
          { title = "Presenterm" }
        )
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
        {
          "<leader>p",
          group = "presenterm",
          icon = { icon = " ", color = "azure" },
        },
      },
    },
  },
  {
    "rmnicola/presenterm.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      partials = {
        directory = "_partials",
        resolve_relative = true,
      },
    },
    keys = {
      -- Standard Plugin Mappings
      { "[s",         "<cmd>Presenterm prev<cr>",      desc = "Prev slide" },
      { "]s",         "<cmd>Presenterm next<cr>",      desc = "Next slide" },
      { "<leader>pn", "<cmd>Presenterm new<cr>",       desc = "New slide" },
      { "<leader>ps", "<cmd>Presenterm split<cr>",     desc = "Split slide" },
      { "<leader>pd", "<cmd>Presenterm delete<cr>",    desc = "Delete slide" },
      { "<leader>py", "<cmd>Presenterm yank<cr>",      desc = "Yank slide" },
      { "<leader>pv", "<cmd>Presenterm select<cr>",    desc = "Select slide" },
      { "<leader>pk", "<cmd>Presenterm move-up<cr>",   desc = "Move slide up" },
      { "<leader>pj", "<cmd>Presenterm move-down<cr>", desc = "Move slide down" },
      { "<leader>pR", "<cmd>Presenterm reorder<cr>",   desc = "Reorder slides" },
      { "<leader>pl", "<cmd>Presenterm list<cr>",      desc = "List slides" },
      { "<leader>pL", "<cmd>Presenterm layout<cr>",    desc = "Select layout" },
      {
        "<leader>pi",
        "<cmd>Presenterm partial include<cr>",
        desc = "Include partial",
      },
      { "<C-e>",      "<cmd>Presenterm exec toggle<cr>", desc = "Toggle exec" },
      { "<leader>pr", "<cmd>Presenterm exec run<cr>",    desc = "Run code block" },
      {
        "<leader>pP",
        "<cmd>Presenterm preview<cr>",
        desc = "Preview presentation",
      },
      -- Custom Mappings
      { "<leader>pe", export_pdf,         desc = "Export as PDF" },
      { "<leader>pp", start_presentation, desc = "Start presentation" },
    },
  },
}
