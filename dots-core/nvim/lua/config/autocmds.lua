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

-- Auto-reload palette and lualine when window gains focus if rice changed
local last_loaded_rice = nil
vim.api.nvim_create_autocmd('FocusGained', {
    desc = 'Reload rice theme when window gains focus',
    callback = function()
        local rice_file = vim.fn.expand('~/.config/rice/current')
        local f = io.open(rice_file, 'r')
        if f then
            local current_rice = f:read('*l')
            f:close()
            if current_rice and last_loaded_rice and current_rice ~= last_loaded_rice then
                last_loaded_rice = current_rice
                local palette_path = vim.fn.stdpath('config') .. '/lua/config/themes/palette.lua'
                local ok, p = pcall(dofile, palette_path)
                if ok and p and p.config then
                    p.config()
                end
                package.loaded['palette.highlights'] = nil
                package.loaded['palette.theme'] = nil
                package.loaded['palette.colors'] = nil
                package.loaded['palette.utils'] = nil
                pcall(function()
                    require('palette').load()
                end)
                if package.loaded['lualine'] then
                    require('lualine').setup {
                        options = {
                            theme = _G.lualine_theme or 'auto',
                        },
                    }
                end
                vim.cmd('redraw!')
            else
                last_loaded_rice = current_rice
            end
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
