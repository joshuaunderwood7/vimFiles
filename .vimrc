" Rebind <Leader> key
" I like to have it here becuase it is easier to reach than the default and
" it is next to ``m`` and ``n`` which I use for navigating between tabs.
 let mapleader = ","

""----My additions----

"This makes space and delete enter insert mode
noremap <Space> i<Space>
noremap <Delete> i<Delete>

"New tabs
noremap <C-t> :tab new<CR>
vnoremap <C-t> :tab new<CR>
inoremap <C-t> :tab new<CR>

"toggle spell check with :spell
:map <F7> :setlocal spell! spelllang=en_us<CR>
"Call aspell on the current buffer file
:map <Leader><F7> :!aspell -c %<CR>

" Quicksave command
" Modified to exit insert mode. Combined with save 
" this will save after every edit.
" this is the best on laptops with crappy Esc key.
 noremap <C-Z> :update<CR>
 vnoremap <C-Z> <C-C>:update<CR>
 inoremap <C-Z> <Esc>:update<CR><Esc>

" Quick GIT commands
" These seemed to crash my vim often.  I think that
" I needed to move it off of G.
""noremap <C-G><C-I> :!git init
""noremap <C-G><C-A> :!git add 
""noremap <C-G><C-U> :!git add -u
""noremap <C-G><C-C> :!git commit -m "

" I care very much about filetypes and sytax highlighting
filetype on
syntax on
filetype plugin indent on

" Quick Make command (moved to ~/.vim/ftplugin/cpp.vim
" This is really useful, but is better if launguage dependent
"" noremap <F5> :make<CR>
"" vnoremap <F5> <C-C>:make<CR>
"" inoremap <F5> <C-O>:make<CR>

"add .tem to c++ FileType (moved to ~/.vim/ftplugin/cpp.vim)
"" au BufNewFile,BufRead *.tem set filetype=cpp

"This is added for vala syntax highlighting
autocmd BufRead *.vala,*.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
au BufRead,BufNewFile *.vala,*.vapi setfiletype vala

"Vala syntax file additionally supports following options
" Disable valadoc syntax highlight
""let vala_ignore_valadoc = 1

" Enable comment strings
""let vala_comment_strings = 1

" Highlight space errors
""let vala_space_errors = 1

" Disable trailing space errors
""let vala_no_trail_space_error = 1

" Disable space-tab-space errors
""let vala_no_tab_space_error = 1

" Minimum lines used for comment syncing (default 50)
""let vala_minlines = 120


" Sample .vimrc file by Martin Brochhaus
" Presented at PyCon APAC 2012
" These settings are pro, some where moved up to 'my additions'
" For a more logical grouping, most below are disabled

" Automatic reloading of .vimrc, ie) changes are immediate
 autocmd! bufwritepost .vimrc source %

" Better copy & paste  
" When you want to paste large blocks of code into vim, press F2 before you
" paste. At the bottom you should see ``-- INSERT (paste) --``.

"" set pastetoggle=<F2>
"" set clipboard=unnamed

" Mouse and backspace
"" set mouse=a  " on OSX press ALT and click
"" set bs=2     " make backspace behave like normal again (very important in gVim)


" Bind nohl
" Removes highlight of your last search
" ``<C>`` stands for ``CTRL`` and therefore ``<C-n>`` stands for ``CTRL+n``
 noremap <C-n> :nohl<CR>
 vnoremap <C-n> :nohl<CR>
 inoremap <C-n> :nohl<CR>


" Quick quit command
 noremap <Leader>e :quit<CR>  " Quit current window
 noremap <Leader>E :qa!<CR>   " Quit all windows


" bind Ctrl+<movement> keys to move around the windows, instead of using Ctrl+w + <movement>
" Every unnecessary keystroke that can be saved is good for your health :)
 map <c-j> <c-w>j
 map <c-k> <c-w>k
 map <c-l> <c-w>l
 map <c-h> <c-w>h


" easier moving between tabs
 map <Leader>n <esc>:tabprevious<CR>
 map <Leader>m <esc>:tabnext<CR>


" map sort function to a key
"" vnoremap <Leader>s :sort<CR>


" easier moving of code blocks
" Try to go into visual mode (v), thenselect several lines of code here and
" then press ``>`` several times.
 vnoremap < <gv  " better indentation
 vnoremap > >gv  " better indentation


" Show whitespace
" MUST be inserted BEFORE the colorscheme command
"" autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
"" au InsertLeave * match ExtraWhitespace /\s\+$/


" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
"" set t_Co=256
"" color wombat256mod


" Enable syntax highlighting
" You need to reload this file for the change to apply
"" filetype off  "Already turned on above, turn on if snipping this
 filetype plugin indent on
"" syntax on    "Already turned on above, turn on if snipping this


" Showing line numbers and length
 set number  " show line numbers
 set tw=79   " width of document (used by gd)
 set nowrap  " don't automatically wrap on load
 set fo-=t   " don't automatically wrap text when typing
 set colorcolumn=80
 highlight ColorColumn ctermbg=233


" easier formatting of paragraphs
"" vmap Q gq
"" nmap Q gqap


" Useful settings
 set history=700
 set undolevels=700


" Real programmers don't use TABs but spaces
 set tabstop=4
 set softtabstop=4
 set shiftwidth=4
 set shiftround
 set expandtab


" Make search case insensitive
 set hlsearch
 set incsearch
 set ignorecase
 set smartcase


" Disable stupid backup and swap files - they trigger too many events
" for file system watchers
 set nobackup
 set nowritebackup
 set noswapfile

" Better navigating through omnicomplete option list
" See http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim
 set completeopt=longest,menuone
 function! OmniPopup(action)
     if pumvisible()
         if a:action == 'j'
             return "\<C-N>"
         elseif a:action == 'k'
             return "\<C-P>"
         endif
     endif
     return a:action
 endfunction

 inoremap <silent><C-j> <C-R>=OmniPopup('j')<CR>
 inoremap <silent><C-k> <C-R>=OmniPopup('k')<CR>

"--------------------Omnifuc setup---------------
"from OmnicppFunc documentation
"while in INSERT mode <C-x><C-o> to activate
"unless acp installed
"" set nocp
filetype plugin on
set omnifunc=syntaxcomplete#Complete
au BufNewFile,BufRead,BufEnter *.cpp,*.hpp,*.tem set omnifunc=omni#cpp#complete#Main
set tags+=$HOME/.vim/tags/cpp_tags

" build tags of your own project with Ctrl-F12
map <C-F12> :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

" Setup Pathogen to manage your plugins
" mkdir -p ~/.vim/autoload ~/.vim/bundle
" curl -so ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/HEAD/autoload/pathogen.vim
" Now you can install any plugin into a .vim/bundle/plugin-name/ folder
"" call pathogen#infect()


" ============================================================================
" Python IDE Setup
" ============================================================================


" Settings for vim-powerline
" cd ~/.vim/bundle
" git clone git://github.com/Lokaltog/vim-powerline.git
"" set laststatus=2


" Settings for ctrlp
" cd ~/.vim/bundle
" git clone https://github.com/kien/ctrlp.vim.git
 ""let g:ctrlp_max_height = 30
 ""set wildignore+=*.pyc
 ""set wildignore+=*_build/*
 ""set wildignore+=*/coverage/*


" Settings for python-mode
" cd ~/.vim/bundle
" git clone https://github.com/klen/python-mode
"" map <Leader>g :call RopeGotoDefinition()<CR>
"" let ropevim_enable_shortcuts = 1
"" let g:pymode_rope_goto_def_newwin = "vnew"
"" let g:pymode_rope_extended_complete = 1
"" let g:pymode_breakpoint = 0
"" let g:pymode_syntax = 1
"" let g:pymode_syntax_builtin_objs = 0
"" let g:pymode_syntax_builtin_funcs = 0
"" map <Leader>b Oimport pdb; pdb.set_trace() # BREAKPOINT<C-c>


" Python folding
" mkdir -p ~/.vim/ftplugin
" wget -O ~/.vim/ftplugin/python_editing.vim http://www.vim.org/scripts/download_script.php?src_id=5492
"" set nofoldenable

