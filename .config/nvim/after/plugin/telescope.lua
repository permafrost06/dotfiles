local builtin = require('telescope.builtin')
local state = require('telescope.state')
local actions = require('telescope.actions')

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})

-- vim.keymap.set('n', '<C-Up>', function()
--     actions.cycle_history_prev(0)
-- end)
-- vim.keymap.set('i', '<C-Down>', function()
--     actions.cycle_history_next(0)
-- end)

vim.keymap.set('n', '<leader>ps', function()
    -- local cached_pickers = state.get_global_key "cached_pickers"
    -- if cached_pickers == nil or vim.tbl_isempty(cached_pickers) then
        require('telescope').extensions.live_grep_args.live_grep_args()
    -- else
    --     require('telescope.builtin').resume()
    -- end
	-- builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
