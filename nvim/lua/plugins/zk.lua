return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>z", group = "My Custom Group" },
      },
    },
  },
  {
    "mickael-menu/zk-nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },

    opts = {
      picker = { name = "telescope" },
    },

    keys = {
      {
        "<leader>zz",
        function()
          local zk = require("zk")
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          -- 1. Custom Action: Presenterm
          local function open_presenterm(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            if _G.Snacks then
              Snacks.terminal("presenterm " .. selection.path, { win = { style = "float" } })
            else
              vim.cmd("tabnew | term presenterm " .. selection.path)
            end
          end

          -- 2. Run the Picker (Use zk.edit, not zk.pickers.notes)
          zk.edit({
            -- Filters (top-level options)
            exclude = { "journal", "lectures" },
            sort = { "modified" },

            -- Telescope Layout & Options
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.95,
              height = 0.95,
              preview_width = 0.7
            },

            attach_mappings = function(_, map)
              map("i", "<C-l>", actions.toggle_selection + actions.move_selection_next)
              map("i", "<C-p>", open_presenterm)
              map("i", "<C-y>", actions.select_default)
              return true
            end,
          })
        end,
        desc = "Zk Match (Custom FZF Style)",
      },
    },
  },
}
