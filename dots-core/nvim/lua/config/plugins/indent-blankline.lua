return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        scope = { enabled = true },
    },
    config = function(_, opts)
        local hooks = require("ibl.hooks")
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            local ok, theme_mgr = pcall(require, "config.theme_manager")
            if ok and theme_mgr and theme_mgr.setup_ibl_highlights then
                theme_mgr.setup_ibl_highlights()
            end
        end)
        require("ibl").setup(opts)
    end,
}
