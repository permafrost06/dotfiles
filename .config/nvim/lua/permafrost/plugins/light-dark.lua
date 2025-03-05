return {
    "permafrost06/auto-dark-mode.nvim",
    opts = {
        update_interval = 1000,
        set_dark_mode = function()
            vim.o.background = "dark"
            vim.cmd.colorscheme('gruvbox-material')
        end,
        set_light_mode = function()
            vim.o.background = "light"
            vim.cmd.colorscheme('gruvbox-material')
        end,
    },
}
