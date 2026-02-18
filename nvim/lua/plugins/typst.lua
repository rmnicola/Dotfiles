-- No state tracking needed - we kill existing processes and let new ones run free

local function get_project_info()
  local cwd = vim.fn.getcwd()
  local dirname = vim.fn.fnamemodify(cwd, ":t")
  -- Remove leading dot from dirname (e.g., .inteli-template -> inteli-template)
  local pdf_name = dirname:gsub("^%.", "")
  local pdf_path = cwd .. "/build/" .. pdf_name .. ".pdf"
  return cwd, pdf_name, pdf_path
end

local function typst_watch()
  local cwd, dirname, _ = get_project_info()

  -- Ensure build directory exists
  vim.fn.mkdir(cwd .. "/build", "p")

  -- Check if main.typ exists
  if vim.fn.filereadable(cwd .. "/main.typ") == 0 then
    vim.notify("main.typ not found in " .. cwd, vim.log.levels.ERROR, { title = "Typst" })
    return
  end

  -- Kill any existing typst watch processes in this directory
  local kill_cmd = string.format("pkill -f 'typst watch.*%s'", vim.fn.shellescape(cwd))
  vim.fn.system(kill_cmd)

  -- Start typst watch detached - let it run free
  local watch_cmd = string.format(
    "cd %s && nohup typst watch main.typ build/%s.pdf > /dev/null 2>&1 &",
    vim.fn.shellescape(cwd),
    dirname
  )
  vim.fn.system(watch_cmd)

  vim.notify("Typst watch started for " .. dirname, vim.log.levels.INFO, { title = "Typst" })
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

  -- Check if sections directory exists
  if vim.fn.isdirectory(sections_dir) == 0 then
    vim.notify("No sections directory found in " .. cwd, vim.log.levels.ERROR, { title = "Typst" })
    return
  end

  -- Get list of .typ files in sections directory
  local files = vim.fn.glob(sections_dir .. "/*.typ", false, true)
  if #files == 0 then
    vim.notify("No .typ files found in sections/", vim.log.levels.WARN, { title = "Typst" })
    return
  end

  -- Prepare items for picker
  local items = {}
  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t")
    table.insert(items, {
      text = filename,
      file = filepath,
    })
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
      local include_line = string.format('#include "sections/%s"', choice)
      vim.api.nvim_put({ include_line }, "l", true, true)
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
