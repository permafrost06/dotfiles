return {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            -- This will not install any breaking changes.
            -- For major updates, this must be adjusted manually.
            version = "^1.0.0",
        },
    },
    config = function()
        local previewers = require('telescope.previewers')

        local new_maker = function(filepath, bufnr, opts)
            opts = opts or {}

            filepath = vim.fn.expand(filepath)
            vim.loop.fs_stat(filepath, function(_, stat)
                if not stat then return end
                if stat.size > 100000 then
                    return
                else
                    previewers.buffer_previewer_maker(filepath, bufnr, opts)
                end
            end)
        end

        require('telescope').setup {
            defaults = {
                buffer_previewer_maker = new_maker,
            }
        }

        require("telescope").load_extension("live_grep_args")
    end
}
