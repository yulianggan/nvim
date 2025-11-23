vim.cmd([[ func SetPythonTitle()
  call setline(1,"# encoding='utf-8")
  call append(line("."), "")
  call append(line(".")+1, "\# @Time: ".strftime("%Y-%m-%d",localtime()))
  call append(line(".")+2, "\# @File: ".("%"))
	call append(line(".")+3, "#!/usr/bin/env")
	call append(line(".")+4, "from icecream import ic")
	call append(line(".")+5, "import os")
 endfunc
]])

vim.cmd([[ autocmd BufNewFile *py exec ":call SetPythonTitle()"]])
-- let curesor move to the end of the file
vim.cmd([[ autocmd BufNewFile *py normal G]])

local preview_stack_trace = function()
	-- 获取当前窗口和缓冲区
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_win_get_buf(win)

	-- 获取光标位置
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local row = cursor_pos[1] - 1   -- 转换为0-indexed

	-- 读取多行内容以提高匹配成功率
	local lines = vim.api.nvim_buf_get_lines(buf, math.max(0, row - 2), row + 3, false)
	local text = table.concat(lines, "\n")

	-- 更健壮的正则表达式模式，支持多种错误格式
	local patterns = {
		-- 标准格式: File "path", line number
		[[File ["']([^"']+)["'], line (%d+)]],
		-- 带in函数的格式: File "path", line number, in function
		[[File ["']([^"']+)["'], line (%d+), in [%w_]+]],
		-- 跨行格式: File "path"\n line number
		[[File ["']([^"']+)["'][\s,]*\n[^%d]*line (%d+)]],
		-- Windows路径格式
		[[File ["']([^"']+)["'], line (%d+)]],
		-- 简写格式: path:line:number
		[[["']([^"']+)["']:(%d+)]],
	}

	local file, lnum

	-- 尝试所有模式
	for _, pattern in ipairs(patterns) do
		file, lnum = text:match(pattern)
		if file and lnum then
			break
		end
	end

	if file and lnum then
		-- 清理文件路径（移除可能的换行和空格）
		file = file:gsub("[\r\n%s]+$", ""):gsub("^[\r\n%s]+", "")

		vim.cmd(":wincmd k")
		vim.api.nvim_command('edit ' .. vim.fn.fnameescape(file))
		vim.api.nvim_win_set_cursor(0, { tonumber(lnum), 0 })
		vim.cmd(":wincmd j")
	else
		-- 如果没有匹配到，显示警告并尝试调试
		vim.notify("未找到有效的堆栈跟踪信息", vim.log.levels.WARN)

		-- 调试信息：显示当前匹配的文本内容
		local debug_text = string.sub(text, 1, 200)     -- 只显示前200字符
		print("调试信息 - 当前文本:")
		print(debug_text)
		print("尝试的手动匹配:")

		-- 尝试手动查找文件路径和行号
		for line_num, line_text in ipairs(lines) do
			if line_text:match("File") or line_text:match("%.py") then
				print("可能包含文件信息的行 " .. (row - 2 + line_num) .. ": " .. line_text)
			end
			if line_text:match("line%s+%d+") then
				print("可能包含行号信息的行 " .. (row - 2 + line_num) .. ": " .. line_text)
			end
		end
	end
end

-- 创建自动命令组来管理终端相关的自动命令
local term_group = vim.api.nvim_create_augroup('TerminalSettings', { clear = true })

-- 防止多实例竞争写入（偶发并发写导致 .tmp.* 堆积）
vim.api.nvim_create_autocmd('VimLeavePre', {
	callback = function() pcall(vim.cmd, 'silent! wshada!') end,
})

-- 在终端打开和进入时都设置按键映射
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
	group = term_group,
	pattern = 'term://*python3*',
	callback = function(args)
		local buf = args.buf
		-- 只对当前缓冲区设置映射
		vim.keymap.set("n", "p", preview_stack_trace, {
			noremap = true,
			silent = true,
			buffer = buf,
			desc = "预览堆栈跟踪"
		})

		-- 可选：添加视觉反馈
		vim.keymap.set("n", "<Leader>p", function()
			vim.notify("按 'p' 跳转到错误位置", vim.log.levels.INFO)
		end, { noremap = true, silent = true, buffer = buf })
	end
})

-- 添加一个命令来测试匹配功能
vim.api.nvim_create_user_command('TestStackTrace', function()
	preview_stack_trace()
end, { desc = '测试堆栈跟踪匹配功能' })



return {
	-- -- "dccsillag/magma-nvim",
	-- -- branch = "origin/sync-with-goose-fork",
	-- -- jupyter nvim
	-- "yuzhegan/magma",
	-- build = ":UpdateRemotePlugins",
	-- config = function()
	-- 	vim.cmd([[nnoremap <silent> <leader>mk :MagmaInit Python3<CR>
	-- 	nnoremap <silent> <leader>m  :MagmaEvaluateOperator<CR>
	-- 	nnoremap <silent> <leader>mm :MagmaEvaluateLine<CR>
	-- 	xnoremap <silent> <leader>m  :<C-u>MagmaEvaluateVisual<CR>
	-- 	nnoremap <silent> <leader>mc :MagmaReevaluateCell<CR>
	-- 	nnoremap <silent> <leader>md :MagmaDelete<CR>
	-- 	nnoremap <silent> <leader>mo :MagmaShowOutput<CR>
	-- 	nnoremap <silent> <leader>ms :MagmaSave<CR>
	--
	-- 	let g:magma_automatically_open_output = v:false
	-- 	let g:magma_image_provider = "ueberzug"
	-- 	let g:magma_save_path = "~/tmp/magma"
	--
	-- 	]])
	-- end,

}
