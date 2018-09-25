"
" Quick Make command (moved to ~/.vim/ftplugin/vala.vim
 noremap <F5> :make<CR>
 vnoremap <F5> <C-C>:make<CR>
 inoremap <F5> <C-O>:make<CR>

"add .vala to vala FileType (moved to ~/.vim/ftplugin/vala.vim)
 syntax on
 filetype on
 "au BufNewFile,BufRead *.vala set filetype=vala

"debugging remap
map \ :cn<CR>
map <C-\> :cp<CR>
map <Leader>\ :clist<CR>

