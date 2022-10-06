" ----my additions----

compiler mvn
set nocscopetag

"" Quick Make command (moved to ~/.vim/ftplugin/cpp.vim
 noremap <F5> :make compile<CR>
 vnoremap <F5> <C-C>:make compile<CR>
 inoremap <F5> <C-O>:make compile<CR>

"debugging remap
map \ :cn<CR>zz
map <Bar> :cp<CR>zz
map <C-\> :copen<CR>
map <Leader>\ :cclose<CR>

" Set tab->spaces and indentation
set tabstop=2
set softtabstop=2
set shiftwidth=2
set textwidth=80
set expandtab
set autoindent
set fileformat=unix

" javacomplete2
nmap <F8> <Plug>(JavaComplete-Imports-AddSmart)
imap <F8> <Plug>(JavaComplete-Imports-AddSmart)

nmap <F9> <Plug>(JavaComplete-Imports-Add)
imap <F9> <Plug>(JavaComplete-Imports-Add)

nmap <F10> <Plug>(JavaComplete-Imports-AddMissing)
imap <F10> <Plug>(JavaComplete-Imports-AddMissing)

nmap <F11> <Plug>(JavaComplete-Imports-RemoveUnused)
imap <F11> <Plug>(JavaComplete-Imports-RemoveUnused)

nmap <leader>jI <Plug>(JavaComplete-Imports-AddMissing)
nmap <leader>jR <Plug>(JavaComplete-Imports-RemoveUnused)
nmap <leader>ji <Plug>(JavaComplete-Imports-AddSmart)
nmap <leader>jii <Plug>(JavaComplete-Imports-Add)

imap <C-j>I <Plug>(JavaComplete-Imports-AddMissing)
imap <C-j>R <Plug>(JavaComplete-Imports-RemoveUnused)
imap <C-j>i <Plug>(JavaComplete-Imports-AddSmart)
imap <C-j>ii <Plug>(JavaComplete-Imports-Add)

nmap <leader>jM <Plug>(JavaComplete-Generate-AbstractMethods)

imap <C-j>jM <Plug>(JavaComplete-Generate-AbstractMethods)

nmap <leader>jA <Plug>(JavaComplete-Generate-Accessors)
nmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
nmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
nmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
nmap <leader>jts <Plug>(JavaComplete-Generate-ToString)
nmap <leader>jeq <Plug>(JavaComplete-Generate-EqualsAndHashCode)
nmap <leader>jc <Plug>(JavaComplete-Generate-Constructor)
nmap <leader>jcc <Plug>(JavaComplete-Generate-DefaultConstructor)

imap <C-j>s <Plug>(JavaComplete-Generate-AccessorSetter)
imap <C-j>g <Plug>(JavaComplete-Generate-AccessorGetter)
imap <C-j>a <Plug>(JavaComplete-Generate-AccessorSetterGetter)

vmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
vmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
vmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)

nmap <silent> <buffer> <leader>jn <Plug>(JavaComplete-Generate-NewClass)
nmap <silent> <buffer> <leader>jN <Plug>(JavaComplete-Generate-ClassInFile)

