"Display Settings
" Show absolute line numbers
set number

" Show relative numbers (useful for quick movement like 5j or 3k)
set relativenumber

set cursorline

" Highlight search results
set hlsearch

syntax on

"Text Display Settings
set linebreak
set wrap

"User Interface Setting Options
set cursorline
set mouse=r
set ruler
set visualbell
set noerrorbells
set laststatus=2



" ================================
" COLOR SCHEME
" ================================
colorscheme desert
set background=dark

" ================================
" INDENTATION & FORMATTING
" ================================

" Use spaces instead of tabs
set expandtab

" Number of spaces that a <Tab> counts for
set tabstop=4

" Number of spaces used for autoindent
set shiftwidth=4

" Number of spaces for <Tab> in insert mode
set softtabstop=4

" Enable smart indentation (good for code/scripts)
set smartindent



" ================================
" BASIC QUALITY OF SEARCH SETTINGS
" ================================

" Show matches as you type
set incsearch

" Ignore case when searching…
set ignorecase

" …unless you type a capital letter
set smartcase

" Show matching brackets/parentheses
set showmatch


" Keep 5 lines visible above/below the cursor
set scrolloff=5

" Keep 5 columns visible left/right of the cursor
set sidescrolloff=5

" ================================
" MISC SETTINGS
" ================================

" Show hidden whitespace (great for YAML, config files, scripts)
set list
set listchars=tab:▸\ ,trail:·,eol:¬

" Set stored history amount 
set history=1000
