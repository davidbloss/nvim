-- General
vim.keymap.set("n", "<leader>w", function()
  vim.cmd("write")
end)
vim.keymap.set("n", "<leader>q", "<CMD>confirm quitall<CR>")
vim.keymap.set("n", "<leader>h", "<CMD>set hlsearch!<CR>")

-- Text movements
vim.keymap.set("n", "Y", "yy")
vim.keymap.set("n", "Y", "yy")
vim.keymap.set("n", "-", "ddp")
vim.keymap.set("n", "_", "ddkP")

-- Surround text
vim.keymap.set("n", '<leader>"', 'viw<ESC>a"<ESC>bi"<ESC>lel')
vim.keymap.set("n", "<leader>'", "viw<ESC>a'<ESC>bi'<ESC>lel")
vim.keymap.set("n", "<leader>[", "viw<ESC>a]<ESC>bi[<ESC>lel")
vim.keymap.set("n", "<leader>(", "viw<ESC>a)<ESC>bi(<ESC>lel")
vim.keymap.set("n", "<leader>{", "viw<ESC>a}<ESC>bi{<ESC>lel")
vim.keymap.set("n", "<leader><", "viw<ESC>a><ESC>bi<<ESC>lel")

-- Buffer navigation
vim.keymap.set("n", "<C-d>", "<C-d>M")
vim.keymap.set("n", "<C-u>", "<C-u>M")
vim.keymap.set("n", "<C-f>", "<C-f>M")
vim.keymap.set("n", "<C-b>", "<C-b>M")
vim.keymap.set("n", "H", "<CMD>bprevious<CR>")
vim.keymap.set("n", "L", "<CMD>bnext<CR>")

-- Window navigation
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<F1>", "<ESC>")
vim.keymap.set("n", "+", "<CMD>NvimTreeFindFileToggle!<CR>")

vim.keymap.set("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>")

-- Git
vim.keymap.set("n", "<leader>G", "<CMD>G<CR>")
vim.keymap.set("n", "<leader>gb", "<CMD>Git blame<CR>")

-- Edit thing
vim.keymap.set("n", "<leader>ez", "<CMD>edit ~/.zshrc<CR>")

-- Lua execute
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", ":<CMD>lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end)

-- Terminal
vim.keymap.set("n", "T", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 20)
  vim.cmd("startinsert")
end)
