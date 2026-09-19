return {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = {
        'DiffviewOpen',
        'DiffviewClose',
        'DiffviewToggleFiles',
        'DiffviewFocusFiles',
        'DiffviewRefresh',
        'DiffviewFileHistory',
    },
    keys = {
        { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git [D]iffview' },
        { '<leader>gD', '<cmd>DiffviewOpen --staged<cr>', desc = 'Git [D]iffview (staged)' },
        { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', desc = 'Git [H]istory (global)' },
        { '<leader>gfh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git [F]ile [H]istory' },
    },
    opts = function()
        local actions = require('diffview.actions')
        return {
            enhanced_diff_hl = true,
            view = {
                merge_tool = {
                    layout = 'diff3_mixed',
                    disable_diagnostics = true,
                },
            },
            keymaps = {
                merge_tool = {
                    { 'n', '<leader>co', actions.conflict_choose('ours'), { desc = 'Conflict choose OURS' } },
                    { 'n', '<leader>ct', actions.conflict_choose('theirs'), { desc = 'Conflict choose THEIRS' } },
                    { 'n', '<leader>cb', actions.conflict_choose('base'), { desc = 'Conflict choose BASE' } },
                    { 'n', '<leader>ca', actions.conflict_choose('all'), { desc = 'Conflict choose ALL' } },
                    { 'n', '<leader>c0', actions.conflict_choose('none'), { desc = 'Conflict choose NONE' } },
                    { 'n', ']x', actions.next_conflict, { desc = 'Next conflict' } },
                    { 'n', '[x', actions.prev_conflict, { desc = 'Prev conflict' } },
                },
            },
        }
    end,
}