set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-scripts/molokai'
Plugin 'chriskempson/vim-tomorrow-theme'
Plugin 'altercation/vim-colors-solarized'

Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-bundler'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-haml'
Plugin 'pangloss/vim-javascript'
Plugin 'tpope/vim-cucumber'
Plugin 'tpope/vim-markdown'
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-git'
Plugin 'timcharper/textile.vim'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'isruslan/vim-es6'

Plugin 'skwp/vim-rspec'
Plugin 'chrisbra/csv.vim'
Plugin 'mmalecki/vim-node.js'
Plugin 'wlangstroth/vim-haskell'
Plugin 'slim-template/vim-slim'
Plugin 'jimenezrick/vimerl'
Plugin 'sunaku/vim-ruby-minitest'
Plugin 'elixir-lang/vim-elixir'
Plugin 'c-brenn/phoenix.vim'
Plugin 'tpope/vim-projectionist'
Plugin 'tpope/vim-liquid'
Plugin 'depuracao/vim-rdoc'
Plugin 'fatih/vim-go'
Plugin 'SirVer/ultisnips'

Plugin 'tpope/vim-unimpaired'
Plugin 'scrooloose/nerdcommenter'
Plugin 'ervandew/supertab'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'sjl/gundo.vim'
Plugin 'tpope/vim-surround'
Plugin 'garbas/vim-snipmate'
Plugin 'tomtom/tlib_vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'scrooloose/syntastic'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'tpope/vim-endwise'
Plugin 'mattn/webapi-vim'
Plugin 'ap/vim-css-color'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'chrisbra/NrrwRgn'
Plugin 'jeetsukumaran/vim-buffergator'
Plugin 'rgarver/Kwbd.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'skalnik/vim-vroom'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-repeat'
Plugin 'honza/vim-snippets'
Plugin 'tpope/vim-dispatch'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'thinca/vim-visualstar'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'elzr/vim-json'
Plugin 'airblade/vim-gitgutter'
Plugin 'sh-dude/ZoomWin'
Plugin 'rizzatti/dash.vim'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'tomtom/tcomment_vim'
Plugin 'kana/vim-textobj-user'
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim'}
Plugin 'sbdchd/neoformat'
Plugin 'prettier/vim-prettier', { 'do': 'yarn install' }
Plugin 'mxw/vim-jsx'
Plugin 'leafgarland/typescript-vim'

Plugin 'posva/vim-vue'

call vundle#end()            " required
filetype plugin indent on    " required