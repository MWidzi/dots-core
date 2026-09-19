return {
    'goolord/alpha-nvim',
    dependencies = {
        'nvim-mini/mini.icons',
        'nvim-lua/plenary.nvim',
    },
    config = function()
        local alpha = require 'alpha'
        local dashboard = require 'alpha.themes.dashboard'
    end,
}
