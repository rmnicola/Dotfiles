return {
  {
    "goerz/jupytext.vim",
    lazy = false, -- We need this to load immediately to handle filetypes
    init = function()
      -- Tell standard vim not to treat ipynb as json
      vim.g.jupytext_enable = 1
      vim.g.jupytext_fmt = "md" -- Convert to Markdown when opening

      -- Optional: Set the style (e.g., "py:percent" for python scripts, "md" for markdown)
      -- "md" is usually best for readability as it renders text cells nicely.
    end,
  },
}
