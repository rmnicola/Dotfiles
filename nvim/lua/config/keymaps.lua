-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local del = vim.keymap.del

-- Buffer navigation
del("n", "[b")
del("n", "]b")
del("n", "<leader>bb")
del("n", "<leader>`")

-- Lazygit
del("n", "<leader>l")
del("n", "<leader>L")
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Keywordprg
del("n", "<leader>K")

-- Floating terminal
del({ "n", "t" }, "<C-/>")
del({ "n", "t" }, "<C-_>")

-- Window navigation
del("n", "<leader>-")
del("n", "<leader>|")
del("n", "<leader>wd")

-- Move by visual line on wrapped text, but keep counted jumps logical
-- (so 10j still respects relativenumber)
map({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
