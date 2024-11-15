call plug#begin()

Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-rooter'
Plug 'arcticicestudio/nord-vim'
Plug 'LnL7/vim-nix'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

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

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local servers = { "gopls", "rust_analyzer", "tsserver","solargraph", "pylsp", "rnix-lsp" }
local servers = { "gopls", "rust_analyzer", "tsserver", "solargraph" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

require('lspconfig').solargraph.setup({
  settings = {
    solargraph = {
      diagnostics = true,  -- Enable diagnostics if not already enabled
      completion = true,
    }
  }
})

require'lspconfig'.tsserver.setup{
  filetypes = {
    "javascript",
    "typescript"
  },
}

nvim_lsp.gopls.setup { on_attach = on_attach, cmd_env = { GOOS = "js", GOARCH = "wasm" } }

-- config = {
--  tsserver = {
--     filetypes = { 'eruby' }
--   }
-- }

--- Set filetype to javascript when opening a .js.erb file
vim.cmd([[autocmd BufNewFile,BufRead *.js.erb set filetype=javascript]])

-- nvim_lsp.config.tsserver = {
--   filetypes = { 'js.erb' },
-- }

-- Check if the tsserver setup function exists before calling it
-- if not nvim_lsp.tsserver then
--     configs.tsserver = {
--         default_config = {
--             cmd = { 'typescript-language-server', '--stdio' },
--             filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'typescript.tsx', 'typescriptreact', 'typescriptreact.tsx', 'typescriptreact.tsx', 'js.erb' },
--             root_dir = nvim_lsp.util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git'),
--         },
--     }
--     nvim_lsp.tsserver = require('nvim_lsp/tsserver')
-- end

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
    luasnip = true;
  };
}

EOF

set background=dark

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
