-- ~/.config/nvim/lua/plugins/linting.lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        -- setting these to an empty table disables the linter for these filetypes
        markdown = {},
        mdx = {},
      },
    },
  },
}
