set nocompatible
syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands
let mapleader=","
call pathogen#infect()
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set nobackup
set nowritebackup
set history=50                  " keep 50 lines of command line history
set ruler                       " show the cursor position all the time

" Color scheme
set background=dark
if has('gui_running')
 colorscheme moria
else
  colorscheme xoria256
endif
highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0
set guifont=Liberation\ Mono:h18
syntax on

" Numbers
set number
set numberwidth=5
