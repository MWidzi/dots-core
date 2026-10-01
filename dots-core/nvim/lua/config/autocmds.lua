-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Set commentstring for Blade files
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'blade',
    callback = function()
        vim.opt_local.commentstring = '{{-- %s --}}'
    end,
})

-- Auto-reload theme and lualine when window gains focus if rice or theme changed
local last_loaded_rice = nil
local last_loaded_theme = nil
vim.api.nvim_create_autocmd('FocusGained', {
    desc = 'Reload rice theme when window gains focus',
    callback = function()
        local theme_mgr = require('config.theme_manager')
        local rice_file = vim.fn.expand('~/.config/rice/current')
        local f = io.open(rice_file, 'r')
        local current_rice = f and f:read('*l') or nil
        if f then
            f:close()
        end

        local current_theme = theme_mgr.get_active_theme()

        if (current_rice and last_loaded_rice and current_rice ~= last_loaded_rice)
            or (current_theme and last_loaded_theme and current_theme ~= last_loaded_theme)
        then
            last_loaded_rice = current_rice
            last_loaded_theme = current_theme
            theme_mgr.apply_theme(current_theme)
        else
            last_loaded_rice = current_rice or last_loaded_rice
            last_loaded_theme = current_theme or last_loaded_theme
        end
    end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end
