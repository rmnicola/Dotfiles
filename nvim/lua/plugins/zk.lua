return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>z", group = "Zk", icon = "" },
      },
    },
  },
  {
    "zk-org/zk-nvim",
    config = function()
      require("zk").setup({
        picker = "snacks_picker",
        picker_options = {
          snacks_picker = {
            layout = { preset = "default" },
            actions = {
              create_from_input = function(picker)
                local title = picker.input.filter.pattern
                picker:close()

                if title and title ~= "" then
                  require("zk.commands").get("ZkNew")(
                    { title = title }
                  )
                else
                  vim.notify(
                    "Cannot create note: Search query is empty",
                    vim.log.levels.WARN
                  )
                end
              end,

              start_presentation = function(picker)
                -- Get the item under the cursor
                local items = picker:selected()
                local item = items[1] -- Just grab the first/cursor item

                if item and item.file then
                  picker:close()
                  -- Your specific Hyprland + Ghostty command
                  local cmd = string.format(
                    "hyprctl dispatch exec '[fullscreen] ghostty --font-size=20 -e presenterm %s'", item.file)
                  vim.fn.jobstart(cmd, { detach = true })
                else
                  vim.notify("No file selected", vim.log.levels.WARN)
                end
              end,

              delete_selected_note = function(picker)
                local items = picker:selected()
                if #items == 0 then return end

                local paths = {}
                for _, item in ipairs(items) do
                  table.insert(paths, item.file)
                end

                -- Confirmation Dialog
                local choice = vim.fn.confirm(
                  "Delete " .. #paths .. " note(s)?\n" .. table.concat(paths, "\n"),
                  "&Yes\n&No",
                  2 -- Default to No
                )

                if choice == 1 then
                  for _, path in ipairs(paths) do
                    os.remove(path)
                  end
                  vim.notify("Deleted " .. #paths .. " note(s)")
                  -- Refresh the picker to remove deleted items from the list
                  picker:find()
                end
              end,

              include_as_partial = function(picker)
                local items = picker:selected()
                if #items == 0 then return end

                local cwd = vim.fn.getcwd()
                local partials_dir = cwd .. "/_partials"

                -- Ensure _partials directory exists
                if vim.fn.isdirectory(partials_dir) == 0 then
                  vim.fn.mkdir(partials_dir, "p")
                end

                local inserted_links = {}

                for _, item in ipairs(items) do
                  local infile = item.file
                  local raw_filename = vim.fn.fnamemodify(infile, ":t")

                  -- Regex: Remove leading digits and hyphen (e.g. "2023...-name.md" -> "name.md")
                  local clean_filename = raw_filename:gsub("^%d+%-", "")

                  local outfile = partials_dir .. "/" .. clean_filename

                  -- Read file content
                  local lines = vim.fn.readfile(infile)
                  local content = {}
                  local in_frontmatter = false
                  local frontmatter_count = 0

                  -- Strip Frontmatter logic
                  for _, line in ipairs(lines) do
                    if line:match("^%-%-%-$") then
                      frontmatter_count = frontmatter_count + 1
                      in_frontmatter = (frontmatter_count < 2)
                    elseif not in_frontmatter and frontmatter_count >= 2 then
                      table.insert(content, line)
                    elseif frontmatter_count == 0 then
                      -- Handle files with no frontmatter at all
                      table.insert(content, line)
                    end
                  end

                  -- Write clean content to clean filename
                  vim.fn.writefile(content, outfile)
                end
                vim.notify("Included " .. #items .. " partials")
                picker:close()
              end,
            },
            win = {
              input = {
                keys = {
                  ["<c-e>"] = {
                    "create_from_input",
                    mode = { "i", "n" },
                    desc = "Create Note from Search"
                  },
                  ["<A-p>"] = {
                    "start_presentation",
                    mode = { "i", "n" },
                    desc = "Presenterm"
                  },
                  ["<A-d>"] = {
                    "delete_selected_note",
                    mode = { "i", "n" },
                    desc = "Delete Note"
                  },
                  ["<C-i>"] = {
                    "include_as_partial",
                    mode = { "i", "n" },
                    desc = "Include Partial"
                  },
                },
              },
            },
          },
        },
        lsp = {
          config = {
            name = "zk",
            cmd = { "zk", "lsp" },
            filetypes = { "markdown" },
            on_attach = function(client, bufnr)
              -- This explicitly disables diagnostics for the current buffer
              -- as soon as ZK attaches to it.
              vim.diagnostic.enable(false, { bufnr = bufnr })
            end,
          },
          auto_attach = {
            enabled = true,
          },
        },
      })
    end,
    keys = {
      { "<leader>zb", "<cmd>ZkBacklinks<cr>", desc = "List backlinks" },
      { "<leader>zC", "<cmd>ZkCd<cr>",        desc = "CWD to notebook root" },
      {
        "<leader>zd",
        "<cmd>ZkNotes { tags = { 'daily' }, sort = { 'created' }  }<cr>",
        desc = "Pick daily note"
      },
      {
        "<leader>zi",
        "<cmd>ZkInsertLink { select = { 'filename', 'title', 'tags' }," ..
        "excludeHrefs = { 'journal' }, sort = { 'modified' } }<cr>",
        desc = "Insert link"
      },
      { "<leader>zI", "<cmd>ZkIndex<cr>", desc = "Index notebook" },
      { "<leader>zl", "<cmd>ZkLinks<cr>", desc = "List links" },
      {
        "<leader>zm",
        "<cmd>ZkNotes { tags = { 'monthly' }, sort = { 'created' }  }<cr>",
        desc = "Pick monthly note"
      },
      {
        "<leader>zn",
        "<cmd>ZkNotes { excludeHrefs = { 'journal' }, sort = { 'modified' } }<cr>",
        desc = "Pick note"
      },
      {
        "<leader>zw",
        "<cmd>ZkNotes { tags = { 'weekly' }, sort = { 'created' }  }<cr>",
        desc = "Pick weekly note"
      },
    }
  }
}
