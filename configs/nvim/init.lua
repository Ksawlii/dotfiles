----------------------------------------------------------------------------
-- ██╗      █████╗ ███████╗██╗   ██╗    ███╗   ██╗██╗   ██╗██╗███╗   ███╗ --
-- ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝    ████╗  ██║██║   ██║██║████╗ ████║ --
-- ██║     ███████║  ███╔╝  ╚████╔╝     ██╔██╗ ██║██║   ██║██║██╔████╔██║ --
-- ██║     ██╔══██║ ███╔╝    ╚██╔╝      ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║ --
-- ███████╗██║  ██║███████╗   ██║       ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║ -- 
-- ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ --
----------------------------------------------------------------------------

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    { "prisma/vim-prisma" },
    { "leafOfTree/vim-svelte-plugin" },
    { "goolord/alpha-nvim" },
    { "nvim-lualine/lualine.nvim" },
    { "nvim-tree/nvim-web-devicons" },
    { "L3MON4D3/LuaSnip" },
    { "windwp/nvim-autopairs" },
    { "nvim-lua/plenary.nvim" },
    { "BurntSushi/ripgrep" },
    { "nvim-telescope/telescope.nvim" },
    { "mrcjkb/rustaceanvim" },
    { "leafgarland/typescript-vim" },
    { "peitalin/vim-jsx-typescript" },
    { "scottmckendry/cyberdream.nvim" },
    { "sbdchd/neoformat" },
    { "lervag/vimtex" },
    { "sakhnik/nvim-gdb" },
    { "OXY2DEV/markview.nvim" },
    { "tpope/vim-commentary" },
    { "yuttie/comfortable-motion.vim" },
    { "mrloop/telescope-git-branch.nvim" },
    { "folke/noice.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "rcarriga/nvim-notify" },
    { "nvim-tree/nvim-tree.lua" },
    { "catppuccin/nvim", as = "catppuccin" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/cmp-emoji" },
    { "Ksawlii/friendly-snippets" },
    { "onsails/lspkind.nvim" },
    { "windwp/nvim-autopairs" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-treesitter/nvim-treesitter", dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" } },
    { "ya2s/nvim-cursorline" },
    { "romgrk/barbar.nvim", dependencies = { "lewis6991/gitsigns.nvim", "nvim-tree/nvim-web-devicons", }, }
  },
  checker = { enabled = false },
})

--------------------------------------------------------------------------
-- ██╗   ██╗ █████╗ ██████╗ ██╗ █████╗ ██████╗ ██╗     ███████╗███████╗ --
-- ██║   ██║██╔══██╗██╔══██╗██║██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝ --
-- ██║   ██║███████║██████╔╝██║███████║██████╔╝██║     █████╗  ███████╗ --
-- ╚██╗ ██╔╝██╔══██║██╔══██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║ --
--  ╚████╔╝ ██║  ██║██║  ██║██║██║  ██║██████╔╝███████╗███████╗███████║ --
--   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝ --
--------------------------------------------------------------------------

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local des = function(desc)
  return { noremap = true, silent = true, desc = desc }
end

-------------------------------------------------------------
--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ ███████╗ --
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ ██╔════╝ --
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗███████╗ --
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║╚════██║ --
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝███████║ --
-- ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝  --
-------------------------------------------------------------

-- CMP
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "luasnip" },
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
    { name = "emoji" },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  experimental = {
    ghost_text = false,
  },
})

-- LuaSnip
require("luasnip.loaders.from_vscode").lazy_load()

-- Mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ts_ls", "gopls", "html", "bashls", "zls" },
  automatic_installation = true,
})

-- LSP
local lspconfig = require("lspconfig")
lspconfig.pyright.setup{}
lspconfig.html.setup{}
lspconfig.bashls.setup{}
lspconfig.zls.setup{}

-- Auto Pairs
require("nvim-autopairs").setup{}

-- Telescope
require("telescope").setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
  },
}

-- Noice
require("noice").setup({
  lsp = {
    progress = {
      enabled = true,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000 / 30,
      view = "notify",
    },
  },
  presets = {
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
})

-- LuaLine
require("lualine").setup({
  extensions = {'nvim-tree'},
  options = {
    icons_enabled = true,
    theme = "catppuccin" 
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {},
  },
  sections = {
    lualine_c = {'filename'},
    lualine_x = {'filetype'},
  },
})

-- Catppuccin
require("catppuccin").setup {
  color_overrides = {
    all = {
      base = "#000000",
      mantle = "#000000",
      crust = "#000000",
    },
  },
}

-- Nvim Tree
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 25,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- Cursorline
require('nvim-cursorline').setup {
  cursorline = {
    enable = true,
    timeout = 1000,
    number = false,
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
}


-- Barbar
vim.g.barbar_auto_setup = false
require('barbar').setup {
  animation = true,
  clickable = true,
  maximum_padding = 1,
  minimum_padding = 1,
  maximum_length = 30,
  gitsigns = {
    added = {enabled = true, icon = '+'},
    changed = {enabled = true, icon = '~'},
    deleted = {enabled = true, icon = '-'},
  },
  filetype = {
    custom_colors = false,
    enabled = true,
  },
  sidebar_filetypes = {
    NvimTree = true,
  },
}

-- Treesitter
require("nvim-treesitter.configs").setup {
 ensure_installed = { "lua", "python", "html", "css" },
 highlight = { enable = true },
 indent = { enable = true },
 textobjects = { enable = true },
}

------------------------------------------------------------------
---██╗  ██╗███████╗██╗   ██╗███╗   ███╗ █████╗ ██████╗ ███████╗ --
-- ██║ ██╔╝██╔════╝╚██╗ ██╔╝████╗ ████║██╔══██╗██╔══██╗██╔════╝ --
---█████╔╝ █████╗   ╚████╔╝ ██╔████╔██║███████║██████╔╝███████╗ --
-- ██╔═██╗ ██╔══╝    ╚██╔╝  ██║╚██╔╝██║██╔══██║██╔═══╝ ╚════██║ --
-- ██║  ██╗███████╗   ██║   ██║ ╚═╝ ██║██║  ██║██║     ███████║ --
-- ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝ --
------------------------------------------------------------------

-- Telescope
map("n", "<Space>gb", ":Telescope git_branches<CR>", des("Git Branches"))
map("n", "<Space>gt", ":Telescope git_status<CR>", des("Git Status"))
map("n", "<Space>th", ":Telescope find_files<CR>", des("Find Files"))

-- Barbar
map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
map('n', '<C-p>',   '<Cmd>BufferPick<CR>', opts)
map('n', '<C-s-p>', '<Cmd>BufferPickDelete<CR>', opts)
map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
map('n', '<Space>bn', '<Cmd>BufferOrderByName<CR>', opts)
map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

-- Nvim Tree
map("n", "<C-n>", ":NvimTreeToggle<CR>", opts)
map("n", "<Space>e", function()
  vim.cmd("wincmd p")
end, opts)

-----------------------------
-- ██╗   ██╗██╗███╗   ███╗ --
-- ██║   ██║██║████╗ ████║ --
-- ██║   ██║██║██╔████╔██║ -- 
-- ╚██╗ ██╔╝██║██║╚██╔╝██║ --
--  ╚████╔╝ ██║██║ ╚═╝ ██║ --
--   ╚═══╝  ╚═╝╚═╝     ╚═╝ --
-----------------------------

vim.cmd.colorscheme "catppuccin"
vim.g.did_load_filetypes = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.signcolumn = "yes"
vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.syntax = 'on'
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = ' '
vim.cmd.set "timeout timeoutlen=3000 ttimeoutlen=100"
vim.g.vimtex_view_method = 'zathura'
vim.opt.wrap = true
vim.opt.whichwrap:append "<>[]hl"
vim.opt.ignorecase = true
vim.opt.smartcase = false

