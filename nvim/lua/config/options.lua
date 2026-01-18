-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.minipairs_disable = true
local opt = vim.opt
opt.autoread = true
opt.autowrite = false
opt.backup = false
opt.belloff = "all"
opt.completeopt = "menuone,noinsert,noselect,preview"
opt.conceallevel = 0
opt.colorcolumn = "80"
opt.laststatus = 0
opt.makeprg = "make"
opt.relativenumber = true
opt.scrolloff = 10
opt.swapfile = false
opt.textwidth = 80
opt.wrap = true
