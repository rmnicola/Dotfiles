return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      -- Disable automatic popup
      list = { selection = { preselect = false, auto_insert = false } },
      menu = { auto_show = false },
    },
    -- This ensures the ghost text (preview) is also off
    -- ghost_text = { enabled = false },
  },
}
