
"Display Settings
" Show absolute line numbers
set number

" Show relative numbers (useful for quick movement like 5j or 3k)
set relativenumber

set cursorline


syntax on

"Text Display Settings
set linebreak
set wrap

"User Interface Setting Options
set cursorline
set mouse=r
set ruler
set visualbell
set visualbell t_vb=                       " turn off error beep/flash¬
set noerrorbells
set novisualbell                            "turn off visual bell¬
set laststatus=2

set paste                                   "2019/12/09 - enables consistent pastes¬
set ls=2                                    "allways show status line¬
set shiftwidth=4                            "numbers of spaces to (auto)indent¬
set nocindent

" ================================
" CGW
" ================================
set sm                                      "show matching braces, somewhat annoying...¬
set showcmd                                 " display incomplete commands¬
set nobackup                                "do not keep a backup file¬
set title                                   "show title in console title bar¬
set ttyfast                                 "smoother changes¬
set modeline                                "last lines in document sets vim mode¬
set modelines=3                             "number lines checked for modelines¬
set shortmess=atI                           "Abbreviate messages¬
set nostartofline                           "don't jump to first character when paging¬

" ================================
" COLOR SCHEME
" ================================
if has("gui_running")
    "See ~/.gvimrc¬
    set guifont=Consolas:h14:cANSI¬
    set lines=50           " height = 50 lines¬
    set columns=200        " width = 200 columns¬
    set background=dark   " adapt colors for background¬
    set selectmode=mouse,key,cmd¬
    colorscheme ron¬
else
    "Options are:blue.vim, darkblue.vim ,default.vim ,delek.vim ,desert.vim ,elflord.vim ,evening.vim ,koehler.vim ,morning.vim ,
    "murphy.vim ,pablo.vim ,peachpuff.vim ,ron.vim ,shine.vim ,slate.vim ,torte.vim ,zellner.vim
    colorscheme default
    " Adapt colors for background
    set background=dark
    " Added for lightline
    set t_Co=256
endif

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
"always set autoindenting on¬
set autoindent



" ================================
" BASIC QUALITY OF SEARCH SETTINGS
" ================================

" Highlight search results
set hlsearch
" Case insensitive searches
"
set ic
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
