-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.ui = { theme = 'catppuccin' }

-- Vim Settings
vim.opt.relativenumber = true
vim.opt.nu = true
vim.o.statuscolumn = '%s %l %r %s'

-- custom keymaps
vim.keymap.set("n", "<leader>mg","<cmd> MavenExec <CR>")

return M
