" =========================
" BASIC SETTINGS
" =========================
set encoding=utf-8
set number
set relativenumber
set hidden
set nowrap
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set cursorline
set mouse=a
set clipboard=unnamedplus
set updatetime=300
set signcolumn=yes
syntax on
filetype plugin indent on
let mapleader=" "

" =========================
" PLUGIN MANAGER (vim-plug)
" =========================
call plug#begin('~/.local/share/nvim/plugged')

" LSP / Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" File tree (Neovim)
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Web syntax
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components'
Plug 'editorconfig/editorconfig-vim'

" UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Productivity
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

call plug#end()

" =========================
" KEYBINDINGS
" =========================
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>e :NvimTreeFocus<CR>
nnoremap <C-p> :Files<CR>
nnoremap <C-f> :Rg<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" =========================
" COC (LSP)
" =========================
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> rn <Plug>(coc-rename)
nmap <silent> K  :call CocActionAsync('doHover')<CR>

" Prettier format
command! -nargs=0 Prettier :CocCommand prettier.formatFile
nnoremap <leader>p :Prettier<CR>

" Tab completion
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" =========================
" NVIM-TREE (LUA)
" =========================
lua << EOF
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
  },
})
EOF

" Auto close if only tree left
autocmd BufEnter * if winnr('$') == 1 && &filetype == 'NvimTree' | quit | endif

" =========================
" AIRLINE
" =========================
let g:airline_powerline_fonts = 1
let g:airline_theme='dark'

" =========================
" FILE TYPES
" =========================
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

