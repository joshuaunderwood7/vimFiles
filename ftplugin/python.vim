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

" Turn on syntax and filetype.  (should already be on)
 syntax on
 filetype on

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
noremap <Leader>b Ofrom pdb import set_trace; set_trace()<ESC>


