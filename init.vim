call plug#begin()

Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-rooter'
Plug 'arcticicestudio/nord-vim'
Plug 'LnL7/vim-nix'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'          " Core autocompletion plugin
Plug 'hrsh7th/cmp-nvim-lsp'      " LSP source for nvim-cmp
Plug 'hrsh7th/cmp-buffer'        " Buffer source for nvim-cmp
Plug 'hrsh7th/cmp-path'          " File path source for nvim-cmp
Plug 'L3MON4D3/LuaSnip'          " Snippets engine
Plug 'saadparwaiz1/cmp_luasnip'  " Snippets source for nvim-cmp

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'nvim-lua/plenary.nvim' " null-ls dependency
Plug 'folke/trouble.nvim'
Plug 'golang/tools/gopls'

call plug#end()

set tabstop=2
set shiftwidth=2
set expandtab
set noswapfile
set number
set autoread
set nowb
set completeopt=menuone,noselect
au FocusGained * :checktime

nnoremap <C-K> <cmd>Telescope grep_string<cr>
nnoremap L <cmd>Telescope live_grep<cr>
nnoremap <F2> :NERDTreeFind <CR>
nnoremap <F3> :NERDTreeToggle <CR>
nnoremap <F4> <cmd>Telescope lsp_document_symbols<cr>
nnoremap <F5> <cmd>Telescope lsp_document_diagnostics<cr>
nnoremap <silent> gd <cmd>Telescope lsp_definitions<cr>
nnoremap <silent> gr <cmd>Telescope lsp_references<cr>

nnoremap <C-P> <cmd>Telescope git_files<cr>
nnoremap <C-B> <cmd>Telescope buffers<cr>
nnoremap <C-X> :bufdo bwipeout<CR>

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"

" changing camel case to snake case
:nnoremap + /\w\+_<CR>
:nnoremap _ f_x~


lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function() vim.lsp.buf.format() end,
  })

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
      vim.diagnostic.open_float(nil, { focusable = false })
  end,
})


-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { "gopls", "rust_analyzer", "ts_ls","solargraph", "pylsp", "rnix-lsp" }
local servers = { "gopls", "ts_ls", "solargraph" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- local go_options = { on_attach = on_attach(true), cmd_env = { GOOS = "js", GOARCH = "wasm" } }

-- nvim_lsp.gopls.setup(go_options)
-- nvim_lsp.golangci_lint_ls.setup(go_options)

require('lspconfig').solargraph.setup({
  settings = {
    solargraph = {
      diagnostics = true,  -- Enable diagnostics if not already enabled
      completion = true,
    }
  }
})

require'lspconfig'.ts_ls.setup{
  filetypes = {
    "javascript",
    "typescript"
  },
}

nvim_lsp.gopls.setup({
  on_attach = on_attach,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Down>'] = cmp.mapping.select_next_item(), -- Navigate down
    ['<Up>'] = cmp.mapping.select_prev_item(), -- Navigate up
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept suggestion
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  })
})

--- Set filetype to javascript when opening a .js.erb file
vim.cmd([[autocmd BufNewFile,BufRead *.js.erb set filetype=javascript]])

-- Configure Pyright LSP
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').pyright.setup({
  capabilities = capabilities, -- Include completion capabilities
  on_attach = function(client, bufnr)
    -- Optional: Add LSP keybindings
    local bufmap = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    bufmap('n', 'gd', vim.lsp.buf.definition)
    bufmap('n', 'K', vim.lsp.buf.hover)
    bufmap('n', '<leader>rn', vim.lsp.buf.rename)
    bufmap('n', '<leader>ca', vim.lsp.buf.code_action)
  end,
})

local null_ls = require("null-ls")
null_ls.setup({
  sources = {},
})

require("trouble").setup({})

-- Ensure live_grep_args is loaded
require("telescope").load_extension("live_grep_args")

-- Define keymap
vim.keymap.set("n", "<leader>fs", function()
  vim.ui.input({ prompt = "Search text: " }, function(search_term)
    if not search_term or search_term == "" then return end

    vim.ui.input({ prompt = "Search path: " }, function(search_path)
      if not search_path or search_path == "" then return end

      require("telescope").extensions.live_grep_args.live_grep_args({
        default_text = search_term,
        search_dirs = { search_path },
        prompt_title = "Search in " .. search_path,
      })
    end)
  end)
end, { desc = "Telescope: Search text in custom path" })

EOF

set background=dark

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
