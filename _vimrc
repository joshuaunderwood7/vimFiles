" Steal this config file. "

" Turn off the bell
""set belloff=all

" Make the shell read my .bashrc
""set shell=/bin/bash\ -i

" Make the shell read my .profile
""set shell=/bin/bash\ --login

" Rebind <Leader> key
 let mapleader = ","
" Rebind ConqueGdb Leader
let g:ConqueGdb_Leader = 'B'

"This makes space and delete enter insert mode
noremap <Space> i<Space>
""noremap <Delete> i<Delete>

"New tabs
noremap <Leader>t :tab new<CR>

"toggle spell check with :spell
noremap<Leader><F7>  :setlocal spell! spelllang=en_us<CR>
"inoremap<F7> <ESC>:setlocal spell! spelllang=en_us<CR>a
"Call aspell on the current buffer file
"noremap <Leader><F7> :!aspell -c %<CR>

" Quicksave command
" Modified to exit insert mode. Combined with save
" this will save after every edit.
" this is the best on laptops with crappy Esc key.
 noremap <C-Z> :update<CR>
 vnoremap <C-Z> <C-C>:update<CR>
 inoremap <C-Z> <Esc>:update<CR><Esc>

" I care very much about filetypes and sytax highlighting
filetype on
syntax on
filetype plugin indent on

" Automatic reloading of .vimrc, ie) changes are immediate
 autocmd! bufwritepost .vimrc source %

" Better copy & paste
" When you want to paste large blocks of code into vim, press F2 before you
" paste. At the bottom you should see ``-- INSERT (paste) --``.
 set pastetoggle=<F2>
 set clipboard=unnamed


" Mouse and backspace
""set mouse=a  " on OSX press ALT and click
set bs=2     " make backspace behave like normal again (very important in gVim)


" Bind nohl
" Removes highlight of your last search
 noremap <Space> :nohl<CR>
" noremap <C-n> :nohl<CR>
" vnoremap <C-n> :nohl<CR>
" inoremap <C-n> <ESC>:nohl<CR> "Leave this one, this is search next!

" move search to center of screen
noremap n nzz
noremap N Nzz

" I've come to like not always working at the very edge of the screen
set scrolloff=12

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

" Buffer swapping
 map <Leader>k <esc>:bprevious<CR>
 map <Leader>l <esc>:bnext<CR>

" easy file open
 map <C-f> <C-w><C-f>

" Better resizing
 map <Leader>- :resize +7<CR>
 map <Leader>= :vertical resize +7<CR>

" Toggle that Ranger/NERDTree (file browsing)
 map <Leader><Tab> :NERDTreeToggle<CR>
 let g:ranger_map_keys = 0
"" map <Leader><Tab> :Ranger<CR>
"" map <Leader><Tab> :Explore<CR>

" easier moving of code blocks
" Try to go into visual mode (v), thenselect several lines of code here and
" then press ``>`` several times.
 vnoremap < <gv  " better indentation
 vnoremap > >gv  " better indentation

" a more portable hippie-complete
""inoremap <C-\> <C-x><C-p>

" Show whitespace
" MUST be inserted BEFORE the colorscheme command
"" autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
"" au InsertLeave * match ExtraWhitespace /\s\+$/


" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
 set t_Co=256
 color wombat256mod
 highlight qfLineNr ctermfg=yellow
"" color darkblue


" Enable syntax highlighting
" You need to reload this file for the change to apply
"" filetype off  " Already turned on above, turn on if snipping this
""  filetype plugin indent on " Already set above, uncomment if copying this
"" syntax on    " Already turned on above, turn on if snipping this


" Showing line numbers and length
 set number  " show line numbers
 set tw=79   " width of document (used by gd)
 set nowrap  " don't automatically wrap on load
 set fo-=t   " don't automatically wrap text when typing
 set colorcolumn=80


" Useful settings
 set history=700
 set undolevels=700


" Real programmers don't use TABs but spaces
set tabstop=8
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab

" This will show tabs, traling whitespace, and newline charaters
"set list
"set listchars=tab:†‡,trail:•
"set listchars=tab:†•


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

"" Better navigating through omnicomplete option list
"" See http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim
" set completeopt=longest,menuone
" function! OmniPopup(action)
"     if pumvisible()
"         if a:action == 'j'
"             return "\<C-N>"
"         elseif a:action == 'k'
"             return "\<C-P>"
"         endif
"     endif
"     return a:action
" endfunction

 inoremap <silent><C-j> <C-R>=OmniPopup('j')<CR>
 inoremap <silent><C-k> <C-R>=OmniPopup('k')<CR>

" Pathogen package management
 execute pathogen#infect()

"" " This makes C-] jumping case sensitive, then turns case-sensitivity off again
"" " go to defn of tag under the cursor
"" fun! MatchCaseTag()
""     let ic = &ic
""     set noic
""     try
""         exe 'tjump ' . expand('<cword>')
""     finally
""        let &ic = ic
""     endtry
"" endfun
"" nnoremap <silent> <c-]> :call MatchCaseTag()<CR>

" This makes tags search up from the current directory to HOME looking for
" tags files, rather than only the current folder.
set tags=./tags;/


" vim-LaTeX stuff
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
"" filetype plugin on " Already set above, uncomment if copying this

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
""set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" OPTIONAL: This enables automatic indentation as you type.
""filetype indent on " Already set above, uncomment if copying this

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'

" Makes vim look for my tags file
set tags=/home/underwood/mytagsfile

" Session saver
noremap <Leader><F4> :mksession!<CR>

" Remake ctags/cscope file from pwd
noremap <Leader><F3> :!cscope -Rb<CR>:cscope reset<CR>

" Make errorfiles work
set errorfile=/home/underwood/compile.out

"" CSCOPE is finally built!

if has("cscope")
  set csprg=/home/underwood/local/bin/cscope
  set csto=0
  ""set cscopetag
  set nocsverb
  " add any database in current directory
  if filereadable("cscope.out")
      cs add cscope.out
  " else add database pointed to by environment
  elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
  endif
  set csverb
  set cscopequickfix=s-,c-,d-,i-,t-,e-

   nmap <Leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>g :cs find g <C-R>=expand("<cword>")<CR><CR>	
   nmap <Leader>cc :cs find c <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>t :cs find t <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
"" nmap <Leader>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
   nmap <Leader>d :cs find d <C-R>=expand("<cword>")<CR><CR>	

endif

" javacomplete2
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" TagBar
nmap <F8> :TagbarToggle<CR>
