set nocompatible              " be iMproved, required
filetype off                  " required
set path+=**
set wildmenu
set clipboard=unnamedplus

" TAG JUMPING:
" Create the 'tags' file, ensure ctags is installed
command! MakeTags !ctags -R .

" NOW WE CAN:
" - Use ^] to jump to tag under cursor
" - Use g^] for ambiguous tags
" - Use ^t to jump back up the tag stack

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
Plugin 'tmhedberg/simpylfold'
Plugin 'valloric/youcompleteme'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'tpope/vim-surround'
Plugin 'rust-lang/rust.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-jdaddy'
Plugin 'alvan/vim-closetag'
Plugin 'raimondi/delimitmate'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-notes'
Plugin 'thaerkh/vim-workspace'
Plugin 'Shougo/vimproc.vim'
Plugin 'idanarye/vim-vebugger'
Plugin 'kevinhui/vim-docker-tools'
Plugin 'nlknguyen/cloudformation-syntax.vim'
Plugin 'tpope/vim-rhubarb'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

" Start platformio test plugins for C and other embedded
Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'

" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" git repos on your local machine (i.e. when working on your own plugin)
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
colo tokyo_metro
"colo industry
syntax on
set background=dark
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set modeline
set number
set t_Co=256
hi WhiteSpaceBol guifg=grey
let python_highlight_all=1
let g:AutoPairs = {'{%':'%}', '"""':'"""', "'''":"'''","'":"'",'"':'"'}
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>'
let g:airline_theme='jellybeans'
"let g:airline_theme='angr'
let g:syntastic_yaml_checkers = ['yamllint']
let g:syntastic_python_checkers = ['python', 'flake8', 'bandit']
let g:syntastic_htmldjango_checkers = ['htmldjango', 'html/eslint']
let g:notes_directories = ['~/.Notes']
let g:workspace_session_directory = $HOME . '/.vim/sessions/'
let g:UltiSnipsExpandTrigger="<f6>"
let g:UltiSnipsJumpForwardTrigger="<f3>"
let g:UltiSnipsUmpBackwardTrigger="<f4>"
let g:UltiSnipsEditSplit="vertical"
set autoindent
set list listchars=tab:>>,trail:*,nbsp:~
set statusline=%F%m%r%h%w\ [TYPE=%Y\ %{&ff}]\
  \ [%l/%L\ (%p%%)
au FileType html let b:delimitMate_autoclose = 0
au FileType htmldjango let b:delimitMate_autoclose = 0
au FileType py set autoindent
au FileType py set smartindent
au FileType py set textwidth=79 " PEP-8 Friendly
set foldmethod=indent
set foldlevel=99
nnoremap <space> za
set hidden
nnoremap <leader>s :ToggleWorkspace<CR>
nmap <leader>T :enew<CR>
nmap <leader>bq :bp <BAR> bd #<CR>
nmap <leader>bl :ls<CR>
nmap <C-l> :bnext<CR>
nmap <C-h> :bprevious<CR>
nmap <C-d> :YcmCompleter GetDoc<CR>
nmap <C-x> :pclose<CR>
nmap <F8> <Esc>:w<CR>:!clear;pytest -vvv %<CR>
nmap <F7> <Esc>:w<CR>:!clear;pytest -vvv --cov=. <CR>
nmap <F5> <Esc>:NERDTreeToggle<CR>
nmap <leader>d :DockerToolsToggle<CR>
nmap <leader>c :SyntasticToggleMode<CR>
hi MatchParen cterm=bold ctermbg=none ctermfg=magenta

" Settings for Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Key bindings for vim-lsp.
nn <silent> <M-d> :LspDefinition<cr>
nn <silent> <M-r> :LspReferences<cr>
nn <f2> :LspRename<cr>
nn <silent> <M-a> :LspWorkspaceSymbol<cr>
nn <silent> <M-l> :LspDocumentSymbol<cr>

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

if executable('ccls')
   au User lsp_setup call lsp#register_server({
      \ 'name': 'ccls',
      \ 'cmd': {server_info->['ccls']},
      \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},
      \ 'initialization_options': {},
      \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
      \ })
endif
