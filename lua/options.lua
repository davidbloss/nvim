local set = vim.keymap.set

-- Window navigation
set("n", "<C-l>", "<C-w>l")
set("n", "<C-h>", "<C-w>h")
set("n", "<C-j>", "<C-w>j")
set("n", "<C-k>", "<C-w>k")
set("n", "<F1>", "<ESC>")
set("n", "<space>E", "<CMD>NvimTreeFindFileToggle<CR>")
set("n", "<space>w", "<CMD>w<CR>")

-- Text movements
set("n", "Y", "yy")
set("n", "Y", "yy")
set("n", "-", "ddp")
set("n", "_", "ddkP")

-- Surrounding text
set("n", '<leader>"', 'viw<ESC>a"<ESC>bi"<ESC>lel')
set("n", "<leader>'", "viw<ESC>a'<ESC>bi'<ESC>lel")
set("n", "<leader>[", "viw<ESC>a]<ESC>bi[<ESC>lel")
set("n", "<leader>(", "viw<ESC>a)<ESC>bi(<ESC>lel")
set("n", "<leader>{", "viw<ESC>a}<ESC>bi{<ESC>lel")
set("n", "<leader><", "viw<ESC>a><ESC>bi<<ESC>lel")

set("n", "<leader>h", "<CMD>set hlsearch!<CR>")
-- vim.keymap.set("n", "H", "BufferLineCyclePrev")
-- vim.keymap.set("n", "L", "BufferLineCycleNext")
