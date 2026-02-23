return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
        local conform = require("conform")
        local util = require("conform.util")

        conform.setup({
            formatters_by_ft = {
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                json = { "prettier" },
                php = { "php_cs_fixer" },
            },
            formatters = {
                php_cs_fixer = {
                    cwd = util.root_file({
                        ".php-cs-fixer.php",
                        ".php-cs-fixer.dist.php",
                        "composer.json",
                    }),
                },
            },
            format_on_save = function(bufnr)
                return {
                    timeout_ms = 3000,
                    lsp_fallback = vim.bo[bufnr].filetype ~= "php",
                }
            end,
        })
    end,
}
