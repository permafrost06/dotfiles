require("neodev").setup({})

local lsp = require("lsp-zero")

lsp.preset("recommended")

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        'ts_ls',
        'eslint',
        'lua_ls'
    },
    handlers = {
        lsp.default_setup,
    }
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = {
        { name = 'nvim_lsp' }
    }
})
--
--[[
lsp.set_preferences({
	sign_icons = { }
})
]]
   --

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

require("lspconfig").intelephense.setup({
    settings = {
        intelephense = {
            stubs = {
                "bcmath",
                "bz2",
                "calendar",
                "Core",
                "curl",
                "date",
                "dba",
                "dom",
                "enchant",
                "fileinfo",
                "filter",
                "ftp",
                "gd",
                "gettext",
                "hash",
                "iconv",
                "imap",
                "intl",
                "json",
                "ldap",
                "libxml",
                "mbstring",
                "mcrypt",
                "mysql",
                "mysqli",
                "password",
                "pcntl",
                "pcre",
                "PDO",
                "pdo_mysql",
                "Phar",
                "readline",
                "recode",
                "Reflection",
                "regex",
                "session",
                "SimpleXML",
                "soap",
                "sockets",
                "sodium",
                "SPL",
                "standard",
                "superglobals",
                "sysvsem",
                "sysvshm",
                "tokenizer",
                "xml",
                "xdebug",
                "xmlreader",
                "xmlwriter",
                "yaml",
                "zip",
                "zlib",
                "wordpress",
                "woocommerce",
                "acf-pro",
                "acf-stubs",
                "wordpress-globals",
                "wp-cli",
                "genesis",
                "polylang",
                "sbi"
            },
            diagnostics = { enable = true },
            files = {
                maxSize = 10000000,
            },
        },
    }
});

lsp.setup()

-- TypeScript project-wide type checking
local function typescript_check()
    -- Find nearest tsconfig.json (package-level)
    local tsconfig = vim.fs.find('tsconfig.json', {
        upward = true,
        path = vim.fn.expand('%:p:h')
    })[1]
    
    if not tsconfig then
        vim.notify('No tsconfig.json found in parent directories', vim.log.levels.ERROR)
        return
    end
    
    local tsconfig_dir = vim.fn.fnamemodify(tsconfig, ':h')
    
    -- Find tsc: check current dir, then search upward for monorepo root
    local tsc_cmd = nil
    local search_dir = tsconfig_dir
    
    -- Search upward for node_modules/.bin/tsc (monorepo support)
    while search_dir ~= '/' do
        local candidate = search_dir .. '/node_modules/.bin/tsc'
        if vim.fn.executable(candidate) == 1 then
            tsc_cmd = candidate
            break
        end
        search_dir = vim.fn.fnamemodify(search_dir, ':h')
    end
    
    -- Fallback to global tsc
    if not tsc_cmd then
        if vim.fn.executable('tsc') == 1 then
            tsc_cmd = 'tsc'
        else
            vim.notify('TypeScript not found. Install with: npm install -g typescript', vim.log.levels.ERROR)
            return
        end
    end
    
    -- Show notification
    vim.notify('Type checking...', vim.log.levels.INFO)
    
    -- Run tsc and capture output (run from tsconfig directory)
    local cmd = string.format('cd %s && %s --noEmit --pretty false 2>&1', 
        vim.fn.shellescape(tsconfig_dir), 
        tsc_cmd
    )
    
    local output = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
        -- No errors
        vim.notify('✓ No type errors found', vim.log.levels.INFO)
        vim.fn.setqflist({}, 'r')  -- Clear quickfix
    else
        -- Parse TypeScript errors into quickfix
        -- Format: file.ts(line,col): error TS1234: message
        local qf_items = {}
        for _, line in ipairs(vim.split(output, '\n')) do
            local file, lnum, col, errcode, msg = line:match('(.+)%((%d+),(%d+)%)%: error (%S+)%: (.+)')
            if file then
                -- Convert relative path to absolute (relative to tsconfig_dir)
                local abs_file = file
                if not vim.startswith(file, '/') then
                    abs_file = tsconfig_dir .. '/' .. file
                end
                
                table.insert(qf_items, {
                    filename = abs_file,
                    lnum = tonumber(lnum),
                    col = tonumber(col),
                    text = string.format('[%s] %s', errcode, msg),
                    type = 'E'
                })
            end
        end
        
        vim.fn.setqflist(qf_items, 'r')
        
        local error_count = #qf_items
        
        if error_count > 0 then
            vim.cmd('copen')
            vim.notify(string.format('Found %d type error(s)', error_count), vim.log.levels.WARN)
        else
            vim.notify('Type check completed but no errors could be parsed', vim.log.levels.WARN)
        end
    end
end

vim.keymap.set('n', '<leader>vq', typescript_check, { desc = 'TypeScript check project' })
