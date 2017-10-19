"My vimrc" 
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdTree'
Plugin 'flazz/vim-colorschemes'
Plugin 'easymotion/vim-easymotion'
Plugin 'jalvesaq/Nvim-R'			
Plugin 'Valloric/YouCompleteMe'
Plugin 'auto-pairs'
Plugin 'git://github.com/kana/vim-operator-user'
Plugin 'git://github.com/rhysd/vim-clang-format'
" All of your Plugins must be added before the following line
call vundle#end()            " required

filetype plugin indent on 
