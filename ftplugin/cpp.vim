" ----my additions----
"
"" Quick Make command (moved to ~/.vim/ftplugin/cpp.vim
 noremap <F5> :make<CR>
 vnoremap <F5> <C-C>:make<CR>
 inoremap <F5> <C-O>:make<CR>

" run myBuildScript and open ~/output.txt in cfile
"noremap <F5> :!~/bin/mymake.sh<CR>
"noremap <F12> :cfile ~/output.txt<CR>

"add .tem to c++ FileType (moved to ~/.vim/ftplugin/cpp.vim)
 syntax on
 filetype on
 au BufNewFile,BufRead *.tem set filetype=cpp

"debugging remap
map \ :cn<CR>zz
map <C-\> :copen<CR>
map <Leader>\ :cclose<CR>

"set K help program back to man
set keywordprg=man
"
"set make back to make
set makeprg=make

" Set tab->spaces and indentation
set tabstop=2
set softtabstop=2
set shiftwidth=2
set textwidth=80
set expandtab
set autoindent
set fileformat=unix

highlight qfLineNr ctermfg=yellow

