return {
    "permafrost06/auto-dark-mode.nvim",
    opts = {
        update_interval = 1000,
        set_dark_mode = function()
            vim.cmd.colorscheme("kanagawa-dragon")
        end,
        set_light_mode = function()
            vim.cmd.colorscheme("kanagawa-lotus")
        end,
    },
}
