local M = {}

---Get the active theme name from ~/.config/rice/nvim_theme or rice context
---@return string
function M.get_active_theme()
    local themes_dir = vim.fn.stdpath('config') .. '/lua/config/themes'

    -- 1. Check explicitly saved theme in ~/.config/rice/nvim_theme
    local theme_file = vim.fn.expand('~/.config/rice/nvim_theme')
    local f = io.open(theme_file, 'r')
    if f then
        local t = f:read('*l')
        f:close()
        if t and t:match('%S') then
            local candidate = t:match('^%s*(.-)%s*$')
            if vim.fn.filereadable(themes_dir .. '/' .. candidate .. '.lua') == 1 then
                return candidate
            end
        end
    end

    -- 2. Fallback to rice-based mapping
    local rice_file = vim.fn.expand('~/.config/rice/current')
    local rf = io.open(rice_file, 'r')
    if rf then
        local current_rice = rf:read('*l')
        rf:close()
        if current_rice == 'miku-teto' then
            return 'catppuccin'
        elseif current_rice == 'inabashell' then
            return 'palette'
        elseif current_rice == 'everforest' then
            return 'everforest'
        end
    end

    -- 3. Check existing themes in config directory
    if vim.fn.filereadable(themes_dir .. '/everforest.lua') == 1 then
        return 'everforest'
    elseif vim.fn.filereadable(themes_dir .. '/palette.lua') == 1 then
        return 'palette'
    elseif vim.fn.filereadable(themes_dir .. '/catppuccin.lua') == 1 then
        return 'catppuccin'
    end

    return 'catppuccin'
end

---Apply the specified or current active theme and update UI components
---@param theme_name string|nil
function M.apply_theme(theme_name)
    theme_name = theme_name or M.get_active_theme()
    _G.theme = theme_name

    -- Invalidate module cache so dynamic changes take effect
    for k in pairs(package.loaded) do
        if k:match('^config%.themes%.') or k:match('^palette') or k:match('^catppuccin') or k:match('^ashen') or k:match('^noirbuddy') or k:match('^everforest') then
            package.loaded[k] = nil
        end
    end

    -- Load the theme spec if present
    local theme_spec_path = vim.fn.stdpath('config') .. '/lua/config/themes/' .. theme_name .. '.lua'
    local spec_applied = false
    if vim.fn.filereadable(theme_spec_path) == 1 then
        local ok, spec = pcall(dofile, theme_spec_path)
        if ok and type(spec) == 'table' and type(spec.config) == 'function' then
            pcall(spec.config)
            spec_applied = true
        end
    end

    -- Ensure colorscheme is applied if not already set by spec
    if not spec_applied or not vim.g.colors_name or not vim.g.colors_name:find(theme_name) then
        pcall(vim.cmd.colorscheme, theme_name)
    end

    -- Refresh indent-blankline (ibl)
    M.setup_ibl_highlights()
    if package.loaded['ibl'] then
        pcall(function()
            require('ibl.highlights').setup()
            require('ibl').refresh_all()
        end)
    end

    -- Refresh lualine
    if package.loaded['lualine'] then
        pcall(function()
            require('lualine').setup {
                options = {
                    theme = _G.lualine_theme or 'auto',
                },
            }
        end)
    end

    pcall(vim.cmd, 'redraw!')
end

---Setup and synchronize highlight groups for indent-blankline (ibl)
function M.setup_ibl_highlights()
    local theme = _G.theme or M.get_active_theme()
    local rice_file = vim.fn.expand('~/.config/rice/current')
    local rf = io.open(rice_file, 'r')
    local current_rice = rf and rf:read('*l') or ''
    if rf then
        rf:close()
    end

    local indent_color, scope_color

    if current_rice == 'inabashell' or (theme == 'palette' and current_rice ~= 'miku-teto') then
        -- inabashell (grayscale palette on #343434 background)
        indent_color = '#454545'
        scope_color = '#858585'
    elseif current_rice == 'everforest' or theme == 'everforest' then
        -- everforest (#272E33 background)
        indent_color = '#374145'
        scope_color = '#859289'
    elseif current_rice == 'miku-teto' then
        -- miku-teto (deep navy #131229 background)
        if theme == 'catppuccin' then
            indent_color = '#2e294e'
            scope_color = '#887d9f'
        elseif theme == 'ashen' then
            indent_color = '#2e294e'
            scope_color = '#887d9f'
        elseif theme == 'noirbuddy' then
            indent_color = '#2e294e'
            scope_color = '#1184a3'
        elseif theme == 'palette' then
            indent_color = '#222043'
            scope_color = '#786c9c'
        else
            indent_color = '#2e294e'
            scope_color = '#887d9f'
        end
    else
        -- General fallback: derive from current theme's Whitespace / LineNr
        local ws = vim.api.nvim_get_hl(0, { name = 'Whitespace', link = false })
        local lnr = vim.api.nvim_get_hl(0, { name = 'LineNr', link = false })
        if ws and ws.fg and lnr and lnr.fg and ws.fg ~= lnr.fg then
            indent_color = string.format('#%06x', ws.fg)
            scope_color = string.format('#%06x', lnr.fg)
        elseif lnr and lnr.fg then
            scope_color = string.format('#%06x', lnr.fg)
            indent_color = string.format('#%06x', lnr.fg)
        end
    end

    if indent_color then
        vim.api.nvim_set_hl(0, 'IblIndent', { fg = indent_color, nocombine = true })
        vim.api.nvim_set_hl(0, 'IblWhitespace', { fg = indent_color, nocombine = true })
    end
    if scope_color then
        vim.api.nvim_set_hl(0, 'IblScope', { fg = scope_color, nocombine = true })
    end
end

return M
