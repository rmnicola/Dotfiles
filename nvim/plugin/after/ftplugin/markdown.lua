-- Set conceallevel to 0 (show everything) when entering a markdown file.
-- If you later toggle "Render Markdown" (<leader>um) ON,
-- that plugin will automatically increase this level to hide things again.
vim.opt_local.conceallevel = 0
vim.diagnostic.enable(false, { bufnr = 0 })
