return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = {
                    normal = {
                        a = { fg = '#454545', bg = '#e1e1e1', gui = 'bold' },
                        b = { fg = '#e1e1e1', bg = '#454545' },
                        c = { fg = '#c7c7c7', bg = nvim_bg },
                    },
                    visual = {
                        a = { fg = '#E95274', bg = '#454545', gui = 'bold' },
                        b = { fg = '#e1e1e1', bg = '#454545' },
                        c = { fg = '#c7c7c7', bg = nvim_bg },
                    },
                    insert = {
                        a = { fg = '#C4C9FC', bg = '#454545', gui = 'bold' },
                        b = { fg = '#e1e1e1', bg = '#454545' },
                        c = { fg = '#c7c7c7', bg = nvim_bg },
                    },
                    replace = {
                        a = { fg = '#F5959F', bg = '#454545', gui = 'bold' },
                        b = { fg = '#e1e1e1', bg = '#454545' },
                        c = { fg = '#c7c7c7', bg = nvim_bg },
                    },
                    command = {
                        a = { fg = '#F4D177', bg = '#454545', gui = 'bold' },
                        b = { fg = '#e1e1e1', bg = '#454545' },
                        c = { fg = '#c7c7c7', bg = nvim_bg },
                    },
                    inactive = {
                        a = { fg = '#000000', bg = '#454545', gui = 'bold' },
                        b = { fg = '#e1e1e1', bg = '#454545' },
                        c = { fg = '#c7c7c7', bg = nvim_bg },
                    },
                },
                component_separators = '',
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                    refresh_time = 16, -- ~60fps
                    events = {
                        'WinEnter',
                        'BufEnter',
                        'BufWritePost',
                        'SessionLoadPost',
                        'FileChangedShellPost',
                        'VimResized',
                        'Filetype',
                        'CursorMoved',
                        'CursorMovedI',
                        'ModeChanged',
                    },
                },
            },
            sections = {
                lualine_a = { { 'mode', separator = { left = '', right = '' }, right_padding = 2 } },
                lualine_b = { 'branch', { 'lsp_status', symbols = { separator = '|' } }, 'diagnostics' },
                lualine_c = { { 'filename', file_status = true, newfile_status = true } },
                lualine_x = { 'encoding', 'filetype' },
                lualine_y = { 'searchcount', 'progress' },
                lualine_z = { { 'location', separator = { right = '', left = '' }, left_padding = 2 } },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        }
    end,
}
