vim.api.nvim_create_autocmd("LspAttach", {
  buffer = 0, -- Apply only to the current markdown buffer
  callback = function()
    vim.diagnostic.enable(false, { bufnr = 0 })
  end,
})
vim.diagnostic.enable(false, { bufnr = 0 })
