" cd to dir containing current file.
command Cdd :cd %:p:h

" Syntax Hilighting
syntax on
filetype on

" Enable line numbers
set number

" Set LocalLeader
let maplocalleader = "\\"

" Enable neocomplete
let g:neocomplete#enable_at_startup = 1

" Use system clipboard
set clipboard=unnamed
vnoremap <C-C> "+y
map <C-V> "+P

" Dark style
set background=dark

" Use spaces instead of tabs
set expandtab
set tabstop=4
set shiftwidth=4

" Enable indent
filetype indent on
filetype plugin indent on

" Use Vim defaults instead of 100% vi compatibility
set nocompatible

" more powerful backspacing
set backspace=indent,eol,start

" Keep 50 lines of command line history.
set history=50
" Show the cursor position all the time.
set ruler
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc


if has('gui_running')
    colorscheme solarized
    set cursorline 
    " set guifont=Deja\ Vu\ Sans\ Mono\ 11
    set guifont=Source\ Code\ Pro\ 11
else
    " colorscheme desert256
    " colorscheme devbox-dark-256
    " colorscheme 245-jungle
    " colorscheme anotherdark
    colorscheme wombat256
endif
