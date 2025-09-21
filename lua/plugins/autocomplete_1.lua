-- autocomplete.lua
local M = {}

-- 工具函数
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local limitStr = function(str)
    if #str > 25 then
        str = string.sub(str, 1, 22) .. "..."
    end
    return str
end

local dartColonFirst = function(entry1, entry2)
    if vim.bo.filetype ~= "dart" then
        return nil
    end
    local entry1EndsWithColon = string.find(entry1.completion_item.label, ":") and entry1.source.name == 'nvim_lsp'
    local entry2EndsWithColon = string.find(entry2.completion_item.label, ":") and entry2.source.name == 'nvim_lsp'
    if entry1EndsWithColon and not entry2EndsWithColon then
        return true
    elseif not entry1EndsWithColon and entry2EndsWithColon then
        return false
    end
    return nil
end

M.config = {
    "hrsh7th/nvim-cmp",
    after = "SirVer/ultisnips",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-calc",
        {
            "onsails/lspkind.nvim",
            lazy = false,
            config = function()
                require("lspkind").init()
            end
        },
        {
            "quangnguyen30192/cmp-nvim-ultisnips",
            config = function()
                require("cmp_nvim_ultisnips").setup {}
            end,
        }
    },
    config = function()
        local lspkind = require("lspkind")
        local cmp = require("cmp")
        local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

        -- 设置补全菜单样式
        local setCompHL = function()
            local fgdark = "#2E3440"
            -- 设置补全菜单高亮...
            -- (保留原有的所有highlight设置)
        end
        setCompHL()

        -- 配置补全
        cmp.setup({
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    vim.fn["UltiSnips#Anon"](args.body)
                end,
            },
            window = {
                completion = {
                    col_offset = -3,
                    side_padding = 0,
                },
                documentation = cmp.config.window.bordered(),
            },
            sorting = {
                comparators = {
                    dartColonFirst,
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.kind,
                },
            },
            formatting = {
                fields = { "kind", "abbr", "menu" },
                maxwidth = 60,
                maxheight = 10,
                format = function(entry, vim_item)
                    local kind = lspkind.cmp_format({
                        mode = "symbol_text",
                        symbol_map = { Codeium = "", },
                    })(entry, vim_item)
                    local strings = vim.split(kind.kind, "%s", { trimempty = true })
                    kind.kind = " " .. (strings[1] or "") .. " "
                    kind.menu = limitStr(entry:get_completion_item().detail or "")
                    return kind
                end,
            },
            sources = cmp.config.sources({
                { name = "ultisnips" },
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
                { name = "nvim_lua" },
                { name = "calc" },
            }),
            mapping = cmp.mapping.preset.insert({
                ['<C-o>'] = cmp.mapping.complete(),
                ["<c-e>"] = cmp.mapping(
                    function()
                        cmp_ultisnips_mappings.compose { "expand", "jump_forwards" } (function() end)
                    end,
                    { "i", "s" }
                ),
                ["<c-n>"] = cmp.mapping(
                    function(fallback)
                        cmp_ultisnips_mappings.jump_backwards(fallback)
                    end,
                    { "i", "s" }
                ),
                ['<c-f>'] = cmp.mapping({
                    i = function(fallback)
                        cmp.close()
                        fallback()
                    end
                }),
                ['<CR>'] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() and cmp.get_active_entry() then
                            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                        else
                            fallback()
                        end
                    end
                }),
                ["<Tab>"] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end,
                }),
                ["<S-Tab>"] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                            fallback()
                        end
                    end,
                }),
            }),
        })
    end
}

return M

