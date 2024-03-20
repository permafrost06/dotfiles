require("permafrost.set")
require("permafrost.lazy")
require("permafrost.remap")
-- vim.cmd[[
--     autocmd BufEnter ~/.config/tmux/worklist
--         \ set signcolumn=no |
--         \ setlocal nonumber |
--         \ setlocal norelativenumber |
--         \ set laststatus=0
-- ]]
--
-- vim.cmd[[
--     autocmd BufEnter ~/.config/tmux/sessionizer_dirs
--         \ set signcolumn=no |
--         \ setlocal nonumber |
--         \ setlocal norelativenumber |
--         \ set laststatus=0
-- ]]

vim.cmd[[
    augroup SpecificFiles
        autocmd!
        autocmd BufRead,BufNewFile ~/.config/tmux/worklist,~/.config/tmux/sessionizer_dirs lua SetSpecialOptions()
    augroup END
]]

function SetSpecialOptions()
    vim.opt_local.signcolumn = "no"
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.laststatus = 0
end

