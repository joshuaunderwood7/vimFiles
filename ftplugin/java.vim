" ----my additions----
"

compiler mvn

"" Quick Make command (moved to ~/.vim/ftplugin/cpp.vim
 noremap <F5> :make<CR>
 vnoremap <F5> <C-C>:make<CR>
 inoremap <F5> <C-O>:make<CR>

"debugging remap
map \ :cn<CR>zz
map <Bar> :cp<CR>zz
map <C-\> :copen<CR>
map <Leader>\ :cclose<CR>

" Set tab->spaces and indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=80
set expandtab
set autoindent
set fileformat=unix

