-- return {
-- 	"lilydjwg/fcitx.vim",
-- 	event = "InsertEnter",
-- }
return {
	"yulianggan/macism.nvim",
	event = "InsertEnter",                                -- 插入模式进入时加载
	opts = {
		default_input_source = "com.apple.keylayout.Colemak", -- 设置默认输入法
	},
	config = function(_, opts)
		-- 只有在 macOS 下才需要处理输入法
		if vim.fn.has("macunix") == 1 then
			local default_input_source = opts.default_input_source or "com.apple.keylayout.Colemak"

			-- 获取当前输入法
			local function get_current_input_source()
				local handle = io.popen("macism")
				if not handle then
					return nil
				end
				local result = handle:read("*a")
				handle:close()
				return result:match("%S+") -- 获取非空的输入法名称
			end

			-- 延迟切换输入法（避免延迟过大）
			local function delayed_switch_input_source(input_source)
				-- 延迟切换输入法，避免影响插入模式的切换
				vim.defer_fn(function()
					vim.loop.spawn("macism", { args = { input_source } }, function() end)
				end, 50) -- 延迟 50ms 执行
			end

			-- 离开插入模式时记录当前输入法，并切换到默认输入法
			local function leave_insert()
				local input_source = get_current_input_source()
				if not input_source then
					return
				end

				-- 如果当前输入法不是默认输入法，保存当前输入法并切换到默认输入法
				if input_source ~= default_input_source then
					vim.b.macism_input_source = input_source
					-- 延迟切换输入法
					delayed_switch_input_source(default_input_source)
				end
			end

			-- 进入插入模式时恢复之前的输入法
			local function enter_insert()
				if vim.b.macism_input_source and vim.b.macism_input_source ~= default_input_source then
					-- 恢复之前的输入法（延迟执行）
					delayed_switch_input_source(vim.b.macism_input_source)
				end
			end

			-- 在离开插入模式时记录输入法
			local function insert_leave()
				local input_source = get_current_input_source()
				if input_source then
					vim.b.macism_input_source = input_source -- 记录当前输入法
				end
			end

			-- 设置自动命令组
			local macism_augroup = vim.api.nvim_create_augroup("macism_augroup", { clear = true })
			vim.api.nvim_create_autocmd("InsertEnter", { callback = enter_insert, group = macism_augroup })
			vim.api.nvim_create_autocmd("InsertLeave", { callback = insert_leave, group = macism_augroup })
			vim.api.nvim_create_autocmd("InsertLeave", { callback = leave_insert, group = macism_augroup })
		end
	end,
}
