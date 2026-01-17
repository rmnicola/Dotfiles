-- nvim/after/ftplugin/markdown.lua

-- 1. Set conceallevel (your existing config)
vim.opt_local.conceallevel = 0

-- 2. Create an autocommand to disable diagnostics *whenever* an LSP attaches
--    This catches nvim-zk, markdownlint, and any others that load late.
vim.api.nvim_create_autocmd("LspAttach", {
  buffer = 0, -- Apply only to the current markdown buffer
  callback = function()
    vim.diagnostic.enable(false, { bufnr = 0 })
  end,
})

-- 3. Just in case diagnostics were already loaded (belt and suspenders)
vim.diagnostic.enable(false, { bufnr = 0 })
