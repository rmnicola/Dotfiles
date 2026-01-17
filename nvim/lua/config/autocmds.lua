-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local group = vim.api.nvim_create_augroup("MacroRecording", { clear = true })

-- Notify when recording starts
vim.api.nvim_create_autocmd("RecordingEnter", {
  group = group,
  callback = function()
    local reg = vim.fn.reg_recording()
    if reg ~= "" then
      vim.notify("Recording macro to register [" .. reg .. "]", vim.log.levels.INFO, {
        title = "Macro Recording",
        icon = "⏺️",
      })
    end
  end,
})

-- Notify when recording stops
vim.api.nvim_create_autocmd("RecordingLeave", {
  group = group,
  callback = function()
    -- We can get the register that was just recorded to
    -- Unfortunately, reg_recording() is empty here, so we assume the user stopped what they started.
    vim.notify("Macro recording stopped", vim.log.levels.INFO, {
      title = "Macro Recording",
      icon = "⏹️",
    })
  end,
})
