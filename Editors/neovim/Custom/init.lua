vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

-- Lazy nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins 
local plugins = {

-- Telescope
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },

-- Treesitter
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},

-- Themes
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }
,
{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
}
}

local opts = {}

-- Configs
require("lazy").setup(plugins, opts)

-- Theme configs
require("catppuccin").setup()
require("tokyonight").setup({
  -- use the night style
  style = "night",
  -- disable italic for functions
  styles = {
    functions = {}
  },
  sidebars = { "qf", "vista_kind", "terminal", "packer" },
  -- Change the "hint" color to the "orange" color, and make the "error" color bright red
  on_colors = function(colors)
    colors.hint = colors.orange
    colors.error = "#ff0000"
  end
})

-- Telescope
local builtin = require("telescope.builtin")

-- Treesitter
local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {"lua","python","c","javascript","cpp","markdown","html","latex"},
  highlight = { enable = true },
  indent = { enable = true },
})


-- Default colorscheme
vim.cmd[[colorscheme tokyonight]]

-- Keyboard shortcuts
vim.keymap.set('n','<C-p>',builtin.find_files, {})
vim.keymap.set('n','<leader>fg',builtin.live_grep, {})

