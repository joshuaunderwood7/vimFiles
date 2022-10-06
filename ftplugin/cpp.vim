" ----my additions----
"
"" Quick Make command (moved to ~/.vim/ftplugin/cpp.vim
 noremap <Leader><F5> :make -j4<CR>
 vnoremap <Leader><F5> <C-C>:make -j4<CR>
 inoremap <Leader><F5> <C-O>:make -j4<CR>

" run myBuildScript and open ~/output.txt in cfile
"noremap <F5> :!~/bin/mymake.sh<CR>
"noremap <F12> :cfile ~/output.txt<CR>
noremap <F9>  :cfile compile.out<CR>
noremap <F10> :ctags .<CR>
noremap <F12> :!./makeall.sh 2>&1 \| tee compile.out<CR>

"add .tem to c++ FileType (moved to ~/.vim/ftplugin/cpp.vim)
 syntax on
 filetype on
 au BufNewFile,BufRead *.h++ set filetype=cpp
 au BufNewFile,BufRead *.tem set filetype=cpp

"debugging remap
noremap \ :cn<CR>zz
noremap <C-\> :copen<CR>
noremap <Leader>\ :cclose<CR>

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

source ~/.vim/plugin/mark.vim

