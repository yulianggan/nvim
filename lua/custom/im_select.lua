-- ======================================================
-- 修正版 im-select.nvim (macOS + fcitx5 + ibus 通用)
-- 功能：
--  - 自动在普通模式切换回英文输入法
--  - 插入模式恢复上次输入法（如搜狗拼音）
--  - hybrid 模式可按需启用
-- ======================================================

local M = {}
M.closed = false

-- ======================================================
-- 辅助函数
-- ======================================================

local function all_trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function determine_os()
	if vim.fn.has("macunix") == 1 then
		return "macOS"
	elseif vim.fn.has("win32") == 1 then
		return "Windows"
	elseif vim.fn.has("wsl") == 1 then
		return "WSL"
	else
		return "Linux"
	end
end

local function is_supported()
	local os = determine_os()
	if os ~= "Linux" then
		return true
	end
	local ims = { "fcitx5-remote", "fcitx-remote", "ibus" }
	for _, im in ipairs(ims) do
		if vim.fn.executable(im) == 1 then
			return true
		end
	end
	return false
end

-- ======================================================
-- 默认配置
-- ======================================================
local C = {
	default_command = { "macism" },
	default_method_selected = "com.apple.keylayout.ABC",
	second_method_selected = "com.sogou.inputmethod.sogou.pinyin",
	hybrid_mode = false,
	set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
	set_previous_events = { "InsertEnter" },
	keep_quiet_on_no_binary = false,
	async_switch_im = true,
}

local function set_default_config()
	local current_os = determine_os()
	if current_os == "macOS" then
		C.default_command = { "macism" }
		C.default_method_selected = "com.apple.keylayout.ABC"
	elseif current_os == "Windows" or current_os == "WSL" then
		C.default_command = { "im-select.exe" }
		C.default_method_selected = "1033"
	else
		C.default_command = { "fcitx-remote" }
		C.default_method_selected = "1"
		if vim.fn.executable("fcitx5-remote") == 1 then
			C.default_command = { "fcitx5-remote" }
			C.default_method_selected = "keyboard-us"
		elseif vim.fn.executable("ibus") == 1 then
			C.default_command = { "ibus", "engine" }
			C.default_method_selected = "xkb:us::eng"
		end
	end
end

local function set_opts(opts)
	if not opts or type(opts) ~= "table" then return end
	for k, v in pairs(opts) do
		if C[k] ~= nil then C[k] = v end
	end
end

-- ======================================================
-- 输入法操作函数
-- ======================================================

local function get_current_select(cmd)
	local command = cmd
	if cmd[1]:find("fcitx5%-remote", 1, true) then
		command = { "fcitx5-remote", "-n" }
	end
	return all_trim(vim.fn.system(command))
end

local function change_im_select(cmd, method)
	local args = { unpack(cmd, 2) }
	if cmd[1]:find("fcitx5%-remote", 1, true) then
		table.insert(args, "-s")
	elseif cmd[1]:find("fcitx%-remote", 1, true) then
		if method == "1" then method = "-c" else method = "-o" end
	end
	table.insert(args, method)

	local handle
	handle, _ = vim.loop.spawn(
		cmd[1],
		{ args = args, detach = true },
		vim.schedule_wrap(function(_, _)
			if handle and not handle:is_closing() then handle:close() end
			M.closed = true
		end)
	)

	if not handle then
		vim.api.nvim_err_writeln("[im-select]: Failed to spawn process for " .. cmd[1])
	end

	if not C.async_switch_im then
		vim.wait(2000, function() return M.closed end, 100)
	end
end

-- ======================================================
-- 状态保存与恢复逻辑
-- ======================================================

-- 离开插入模式：保存当前输入法 → 切换回英文
local function restore_default_im()
	local current = get_current_select(C.default_command)
	if current ~= C.default_method_selected then
		vim.g["im_select_saved_state"] = current
		change_im_select(C.default_command, C.default_method_selected)
		vim.notify("[im-select] 保存并切回英文：" .. tostring(current), vim.log.levels.DEBUG)
	end
end

-- 进入插入模式：恢复上次输入法
local function restore_previous_im()
	local saved = vim.g["im_select_saved_state"]
	if not saved or saved == "" then return end
	local current = get_current_select(C.default_command)
	if current ~= saved then
		change_im_select(C.default_command, saved)
		vim.notify("[im-select] 恢复输入法：" .. tostring(saved), vim.log.levels.DEBUG)
	end
end

-- ======================================================
-- 可选 hybrid 模式（实验性）
-- ======================================================
local function hybrid_im_mode()
	local line = vim.fn.getline(".")
	local col = vim.fn.col(".") - 1
	if col <= 0 then return end
	local char = line:sub(col, col)
	if not char then return end

	if char:match("[%a%d%s%p]") then
		restore_default_im()
	else
		restore_previous_im()
	end
end

-- ======================================================
-- 主入口
-- ======================================================
M.setup = function(opts)
	if not is_supported() then return end

	set_default_config()
	set_opts(opts or {})

	if vim.fn.executable(C.default_command[1]) ~= 1 then
		if not C.keep_quiet_on_no_binary then
			vim.api.nvim_err_writeln("[im-select]: command not found: " .. C.default_command[1])
		end
		return
	end

	local group_id = vim.api.nvim_create_augroup("im-select", { clear = true })

	if #C.set_previous_events > 0 then
		vim.api.nvim_create_autocmd(C.set_previous_events, {
			callback = restore_previous_im,
			group = group_id,
		})
	end

	if #C.set_default_events > 0 then
		vim.api.nvim_create_autocmd(C.set_default_events, {
			callback = restore_default_im,
			group = group_id,
		})
	end

	if C.hybrid_mode then
		vim.api.nvim_create_autocmd("TextChangedI", {
			callback = hybrid_im_mode,
			group = group_id,
		})
	end

	vim.notify("[im-select] 已加载，当前默认输入法：" .. C.default_method_selected, vim.log.levels.INFO)
end

return M
