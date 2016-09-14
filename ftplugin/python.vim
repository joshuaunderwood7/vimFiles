" ----my additions----
"
" Quick Make command (moved to ~/.vim/ftplugin/python.vim
 noremap <F5> :!python %<CR>
 vnoremap <F5> <C-C>:!python %<CR>
 inoremap <F5> <C-O>:!python %<CR>

 noremap \ :cne<CR>
 noremap \| :cpre<CR>
" noremap \ :lne<CR>
" noremap \| :lpre<CR>

" Enable folding
 set foldmethod=indent
 set foldlevel=99

" PEP-8 whitespace and tabs
 set tabstop=4
 set softtabstop=4
 set shiftwidth=4
 set textwidth=80
 set expandtab
 set autoindent
 set fileformat=unix

" pdb macro
""noremap <Leader>b Ofrom pdb import set_trace; set_trace()<ESC>
noremap <Leader>b Ofrom ipdb import set_trace; set_trace()<ESC>

" use :make for python syntax check and run.
autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd BufRead *.py nmap <F5> :!python %<CR>

" Set's protable pydoc call for pydoc.vim
let g:pydoc_cmd = 'python -m pydoc' 

" if you want to open pydoc files in vertical splits or tabs, 
" give the appropriate command in your .vimrc with: 
""let g:pydoc_open_cmd = 'vsplit' 
""let g:pydoc_open_cmd = 'tabnew' 

" The script will highlight the search term by default. To disable 
" this behaviour put in your .vimrc: 
""let g:pydoc_highlight=0 
