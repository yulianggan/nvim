# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive Neovim configuration specifically designed for Colemak keyboard layout users. The configuration uses Lua as the primary configuration language and Lazy.nvim as the plugin manager.

## Architecture

### Core Structure
- `init.lua`: Entry point that loads all configuration modules
- `lua/defaults.lua`: Core Neovim settings and behavior configuration
- `lua/keymaps.lua`: All key mappings and shortcuts
- `lua/plugins.lua`: Plugin manager setup and plugin loading
- `lua/machine_specific.lua`: User-specific configurations (auto-generated from template)
- `lua/lsp/`: LSP configuration and server setups
- `lua/plugins/`: Individual plugin configurations (modular approach)
- `lua/custom_plugins/`: Custom plugin implementations
- `ftplugin/`: Filetype-specific configurations

### Plugin Architecture
The configuration uses a modular plugin system where each plugin has its own configuration file in `lua/plugins/`. The main `plugins.lua` file loads all plugin configurations using Lazy.nvim's table-based setup.

Major plugin categories:
- **Language Support**: LSP, autocompletion, syntax highlighting via Treesitter
- **File Navigation**: Telescope, FZF, Yazi file manager
- **UI Enhancement**: Statusline, tabline, scrollbar, winbar
- **Text Editing**: Surround, multi-cursor, leap motion, snippets
- **Development Tools**: Debugger, Git integration, copilot
- **Language-Specific**: Flutter, Go, Python, LaTeX support

### LSP Configuration
LSP setup is centralized in `lua/lsp/init.lua` with individual server configurations in `lua/lsp/servers/`. The configuration includes:
- Mason for LSP server management
- Format-on-save for specific filetypes
- Diagnostic display customization
- Per-buffer keymaps setup via LspAttach autocmd

## Key Remapping Philosophy

This configuration remaps fundamental Vim keys for Colemak layout:
- `k` becomes INSERT mode (instead of `i`)
- Movement keys: `u` (up), `e` (down), `n` (left), `i` (right)
- All commands using `i` should use `k` instead (e.g., `ciw` becomes `ckw`)

## Development Workflows

### Plugin Management (Lazy.nvim)
- `:Lazy` - Open plugin manager UI
- `<SPC>i` - Install plugins
- `<SPC>u` - Update plugins
- `<SPC>s` - Sync plugins
- `<SPC>cl` - Clean unused plugins

### LSP Development
The configuration supports multiple language servers:
- TypeScript/JavaScript (ts_ls, eslint, biome)
- Python (pyright)
- Go (gopls)
- Lua (lua_ls)
- Flutter/Dart
- Web technologies (HTML, CSS, JSON, Tailwind)
- LaTeX (texlab)
- Infrastructure (Docker, Terraform, Ansible)

Format-on-save is enabled for most languages. To disable for a specific filetype, modify the `format_on_save_filetypes` table in `lua/lsp/init.lua`.

### File Structure Navigation
- `tt` - Toggle file explorer (coc-explorer)
- `R` - Open Ranger file browser
- `<C-p>` - FZF file finder
- `<C-f>` - Search file contents
- `<C-w>` - FZF buffer list

### Custom Features
- **Vertical Cursor Movement**: Custom Colemak-optimized movement using `[` and `'` keys with middle row as numbers
- **Compile/Run**: `r` key runs current file based on filetype
- **Swap Ternary**: `<leader>st` to swap ternary operator conditions
- **ASCII Art**: `tx` followed by text creates figlet ASCII art

## Machine-Specific Configuration

The `lua/machine_specific.lua` file is auto-generated from `default_config/_machine_specific_default.lua` on first run. Customize this file for:
- Python path configuration
- Author name for snippets
- Browser preferences
- Flutter device settings
- Debugger paths

## Troubleshooting

### Health Checks
Run `:checkhealth` to verify configuration and dependencies.

### Common Issues
- Missing language servers: Use `:Mason` to install required LSP servers
- Autocomplete not working: Check if `autocomplete_configured` flag is properly set in LSP attach
- Key mappings not working: Remember the Colemak remapping (`k` for insert, `ueni` for movement)

### Dependencies
External tools required for full functionality:
- `npm` packages: `vscode-langservers-extracted`, `@ansible/ansible-language-server`
- System tools: `ctags`, `fzf`, `ag` (the_silver_searcher), `figlet`, `xclip` (Linux)
- Python packages: `pynvim`, `debugpy`