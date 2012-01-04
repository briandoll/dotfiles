set nocompatible                " incompatibility with vi to enable the awesom of vim
syntax enable                   " how is this not a default?
set encoding=utf-8              " we are the world
set showcmd                     " display incomplete commands
let mapleader=","               " cargo-culted but I like it
call pathogen#infect()          " manage plugins via /bundle with pathogen`
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set linebreak                   " wrap lines on words, not characters
set tabstop=2 shiftwidth=2      " a tab is two spaces
set expandtab                   " use spaces, not tabs
set backspace=indent,eol,start  " backspace through everything in insert mode

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set nobackup                    " livin on the edge
set nowritebackup               " do not litter
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
set number                      " enable line numbers
set numberwidth=5               " and align them nicely

" Mapping
" move up and down visual lines, handy for wrapped lines
map k gk
map j gj
