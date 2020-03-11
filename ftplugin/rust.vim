
"debugging remap
noremap \ :cn<CR>zz
noremap <Bar> :cp<CR>zz
noremap <C-\> :copen<CR>
noremap <Leader>\ :cclose<CR>
noremap <F5> :make check<CR>
noremap <F6> :!cargo run<CR>

"
""command -nargs=1 KeywordprgRust !echo https://doc.rust-lang.org/std/index.html?search=<args> | xargs xdg-open
command! -nargs=1 KeywordprgRust !echo https://doc.rust-lang.org/std/index.html?search=<args> | xargs wget 
set keywordprg=:KeywordprgRust
