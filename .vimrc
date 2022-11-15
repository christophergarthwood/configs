set nocompatible                            "use vim defaults
filetype off                                "required

filetype plugin indent on                   "required

"----Cursor Management--------------------------------------------------------------------------------
:autocmd InsertEnter * set cul
:autocmd InsertLeave * set nocul
if has("autocmd")
  au VimEnter,InsertLeave * silent execute '!echo -ne "\e[1 q"' | redraw!
  au InsertEnter,InsertChange *
    \ if v:insertmode == 'i' | 
    \   silent execute '!echo -ne "\e[5 q"' | redraw! |
    \ elseif v:insertmode == 'r' |
    \   silent execute '!echo -ne "\e[3 q"' | redraw! |
    \ endif
  au VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
endif
"----Commentary Configuration-------------------------------------------------------------------------
                                            "use gcc for a single line
                                            "use gc# to comment out a series of lines
"----Training Whitespace Configuration----------------------------------------------------------------
                                            "Use :FixWhitespace to clean up 


"----Copy/Paste/Insertion/Tabs----------------------------------------------------------------------
set paste                                   "2019/12/09 - enables consistent pastes
set ls=2                                    "allways show status line
set expandtab                               "tabs are converted to spaces, use only when required
set tabstop=4                               "numbers of spaces of tab character
set shiftwidth=4                            "numbers of spaces to (auto)indent
set scrolloff=3                             "keep 3 lines when scrolling
set autoindent                              "always set autoindenting on
"set noautoindent
set smartindent                             "smart indent
"set nosmartindent
"set cindent                                "cindent
set nocindent

"----Tab Movement (just a note)----------------------------------------------------------------------
                                            "Ctrl+W, then arrow key to move between tabs

"----Syntax/Look/Feel--------------------------------------------------------------------------------
syntax on                                   "syntax highlighing
set sm                                      "show matching braces, somewhat annoying...
"set nowrap                                 "don't wrap lines
set showcmd                                 " display incomplete commands
set number                                  "show line numbers
set ruler                                   " show the cursor position all the time
set visualbell t_vb=                        " turn off error beep/flash
set novisualbell                            "turn off visual bell
set nobackup                                "do not keep a backup file
set title                                   "show title in console title bar
set ttyfast                                 "smoother changes
"set ttyscroll=0                            "turn off scrolling, didn't work well with PuTTY
set modeline                                "last lines in document sets vim mode
set modelines=3                             "number lines checked for modelines
set shortmess=atI                           "Abbreviate messages
set nostartofline                           "don't jump to first character when paging
"set whichwrap=b,s,h,l,<,>,[,]              "move freely between files
"set viminfo='20,<50,s10,h
"set autowrite                              "auto saves changes when quitting and swiching buffer

"----Searching---------------------------------------------------------------------------------------
set ic                                      "2013/02/20 - case insentive searches 
set hlsearch                                "highlight searches
set incsearch                               "do incremental searching
set ignorecase                              "ignore case when searching 
"set noignorecase                           "don't ignore case


"----Unix/Windows/UI---------------------------------------------------------------------------------
if has("gui_running")
     "See ~/.gvimrc
     set guifont=Consolas:h14:cANSI
     set lines=50           " height = 50 lines
     set columns=200        " width = 200 columns
     set background=dark   " adapt colors for background
     set selectmode=mouse,key,cmd
     set keymodel=
	 colorscheme ron
else
	 "Options are:blue.vim, darkblue.vim ,default.vim ,delek.vim ,desert.vim ,elflord.vim ,evening.vim ,koehler.vim ,morning.vim ,murphy.vim ,pablo.vim ,peachpuff.vim ,ron.vim ,shine.vim ,slate.vim ,torte.vim ,zellner.vim
     " Added solarized, monokai
     colorscheme monokai                    "use this color scheme
     " colorscheme default
     set background=dark                    "adapt colors for background
     set t_Co=256                           "added for lightline
endif


