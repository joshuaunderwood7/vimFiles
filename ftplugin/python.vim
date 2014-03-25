" ----my additions----
"
" Quick Make command (moved to ~/.vim/ftplugin/python.vim
 noremap <F5> :!python %<CR>
 vnoremap <F5> <C-C>:!python %<CR>
 inoremap <F5> <C-O>:!python %<CR>

"Turn on syntax and filetype.  (should already be on)
 syntax on
 filetype on
