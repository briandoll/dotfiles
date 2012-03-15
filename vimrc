set nocompatible                " incompatibility with vi to enable the awesom of vim
syntax enable                   " how is this not a default?
set encoding=utf-8              " we are the world
set showcmd                     " display incomplete commands
let mapleader=","               " cargo-culted but I like it
let g:mapleader = ","           " ditto
call pathogen#infect()          " manage plugins via /bundle with pathogen`
filetype plugin indent on       " load file type plugins + indentation
set autoread                    " automatically reload files that have changed outside vim
set clipboard=unnamed           " use the system clipboard by default

"" Whitespace
set wrap linebreak nolist       " wrap lines on words, not characters
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
set directory=/tmp              " write swap files in /tmp
set history=50                  " keep 50 lines of command line history
set ruler                       " show the cursor position all the time
set list listchars=trail:.,tab:>. " highlight trailing whitespace, etc.

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

" set term so it displays properly in tmux
if !has("gui_running")
  set term=screen-256color
endif

" Numbers
set number                      " enable line numbers
set numberwidth=5               " and align them nicely

" Mapping
" move up and down visual lines, handy for wrapped lines
map k gk
map j gj

" Restore cursor position when re-opening a file
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" copy all text in the file
map <leader>ca :%y+<CR>
" close the current buffer
map <leader>w :bd<CR>
" clear search results
map <leader>cs :noh<CR>
" reload Command-T configuration and cache
map <leader>tf :CommandTFlush<CR>
" reload vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>
" open current file in defult app
map <leader>o :!open %
" turn off list for prose
map <leader>prose :set nolist<CR>:set spell

