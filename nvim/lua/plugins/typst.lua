-- No state tracking needed - we kill existing processes and let new ones run free

local function get_project_info()
  local cwd = vim.fn.getcwd()
  local filename_with_path = vim.fn.expand("%:r")
  local filename = vim.fn.fnamemodify(filename_with_path, ":t")
  local pdf_path = cwd .. "/build/" .. filename .. ".pdf"
  return cwd, filename, pdf_path
end

local function typst_watch()
  local cwd, filename, _ = get_project_info()
  local current_file = vim.fn.expand("%:p")

  -- Ensure build directory exists
  vim.fn.mkdir(cwd .. "/build", "p")

  -- Check if current file exists
  if vim.fn.filereadable(current_file) == 0 then
    vim.notify("Current file not found: " .. current_file, vim.log.levels.ERROR, { title = "Typst" })
    return
  end

  -- Kill any existing typst watch processes in this directory
  local kill_cmd = string.format("pkill -f 'typst watch.*%s'", vim.fn.shellescape(cwd))
  vim.fn.system(kill_cmd)

  -- Start typst watch detached - let it run free
  local watch_cmd = string.format(
    "cd %s && nohup typst watch %s build/%s.pdf > /dev/null 2>&1 &",
    vim.fn.shellescape(cwd),
    vim.fn.shellescape(current_file),
    filename
  )
  vim.fn.system(watch_cmd)

  vim.notify("Typst watch started for " .. filename, vim.log.levels.INFO, { title = "Typst" })
end

local function typst_present()
  local _, _, pdf_path = get_project_info()

  -- Check if PDF exists
  if vim.fn.filereadable(pdf_path) == 0 then
    vim.notify("PDF not found: " .. pdf_path, vim.log.levels.ERROR, { title = "Typst" })
    return
  end

  -- Open evince in fullscreen presentation mode
  local cmd_fmt = "hyprctl dispatch exec '[fullscreen] evince --presentation %s'"
  local cmd = string.format(cmd_fmt, vim.fn.shellescape(pdf_path))
  vim.fn.jobstart(cmd, { detach = true })

  vim.notify("Starting presentation...", vim.log.levels.INFO, { title = "Typst" })
end

local function typst_include_partials()
  local cwd = vim.fn.getcwd()
  local sections_dir = cwd .. "/sections"
  local problems_dir = cwd .. "/problems"

  local items = {}

  -- Check sections directory
  if vim.fn.isdirectory(sections_dir) == 1 then
    local section_files = vim.fn.glob(sections_dir .. "/*.typ", false, true)
    for _, filepath in ipairs(section_files) do
      local filename = vim.fn.fnamemodify(filepath, ":t")
      table.insert(items, {
        text = filename,
        dir = "sections",
      })
    end
  end

  -- Check problems directory
  if vim.fn.isdirectory(problems_dir) == 1 then
    local problem_files = vim.fn.glob(problems_dir .. "/*.typ", false, true)
    for _, filepath in ipairs(problem_files) do
      local filename = vim.fn.fnamemodify(filepath, ":t")
      table.insert(items, {
        text = filename,
        dir = "problems",
      })
    end
  end

  if #items == 0 then
    vim.notify("No .typ files found in sections/ or problems/", vim.log.levels.WARN, { title = "Typst" })
    return
  end

  -- Use vim.ui.select for simple picker
  local choices = {}
  for _, item in ipairs(items) do
    table.insert(choices, item.text)
  end

  vim.ui.select(choices, {
    prompt = "Select partial to include:",
    kind = "typst_partials",
  }, function(choice)
    if choice then
      -- Find the selected item to get the directory
      for _, item in ipairs(items) do
        if item.text == choice then
          local include_line = string.format('#include "%s/%s"', item.dir, choice)
          vim.api.nvim_put({ include_line }, "l", true, true)
          break
        end
      end
    end
  end)
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        {
          "<leader>p",
          group = "typst",
          icon = { icon = "📝", color = "azure" },
        },
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    optional = true,
    enabled = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        typst_lsp = {
          settings = {
            exportPdf = "never",
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "typst" })
    end,
  },
  {
    "kaarmu/typst.vim",
    ft = "typst",
    lazy = false,
    keys = {
      { "<leader>pp", typst_present,          desc = "Start presentation" },
      { "<leader>pw", typst_watch,            desc = "Start watch" },
      { "<leader>pi", typst_include_partials, desc = "Include partials" },
    },
  },
}
