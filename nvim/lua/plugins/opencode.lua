return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>o", group = "opencode", icon = "🧠" },
      },
    }
  },
  {
    "nickjvandyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    -- Define your configuration settings here
    opts = {
      -- Your configuration goes here, e.g.:
      -- events = { reload = true },
    },
    config = function(_, opts)
      -- The plugin expects a global variable, so we pass the opts table to it
      vim.g.opencode_opts = opts

      -- Required for `opts.events.reload`
      vim.o.autoread = true
    end,
    -- LazyVim-style keymaps for lazy loading
    keys = {
      {
        "<leader>oa",
        function() require("opencode").ask("@this: ", { submit = true }) end,
        mode = { "n", "x" },
        desc = "Opencode Ask",
      },
      {
        "<leader>os",
        function() require("opencode").select() end,
        mode = { "n", "x" },
        desc = "Opencode Select/Action",
      },
      {
        "<leader>ot",
        function() require("opencode").toggle() end,
        mode = { "n", "t" },
        desc = "Toggle Opencode Window",
      },
      -- Operator mappings
      {
        "<leader>oo",
        function() return require("opencode").operator("@this ") end,
        mode = { "n", "x" },
        expr = true,
        desc = "Opencode Operator (Range)",
      },
      {
        "<leader>ol",
        function() return require("opencode").operator("@this ") .. "_" end,
        mode = { "n" },
        expr = true,
        desc = "Opencode Current Line",
      },
    },
  },
}
