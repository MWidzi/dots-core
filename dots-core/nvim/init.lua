vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

local theme_mgr = require 'config.theme_manager'
_G.theme = theme_mgr.get_active_theme()

require 'config.autolayout'
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'
