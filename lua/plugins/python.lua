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
