" ----my additions----
"
" Quick Make command (moved to ~/.vim/ftplugin/cpp.vim
 noremap <F5> :make<CR>
 vnoremap <F5> <C-C>:make<CR>
 inoremap <F5> <C-O>:make<CR>

"add .tem to c++ FileType (moved to ~/.vim/ftplugin/cpp.vim)
 syntax on
 filetype on
 au BufNewFile,BufRead *.tem set filetype=cpp

"debugging remap
map \ :cn<CR>
map <C-\> :cp<CR>
map <Leader>\ :clist<CR>
