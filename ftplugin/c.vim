


" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
set cscopetag

" check cscope for definition of a symbol before checking ctags: set to 1
" if you want the reverse search order.
set csto=0

" show msg when any other cscope db added
set cscopeverbose  

"" nmap <Leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>g :cs find g <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>c :cs find c <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>t :cs find t <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
"" nmap <Leader>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
"" nmap <Leader>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
"" nmap <Leader>d :cs find d <C-R>=expand("<cword>")<CR><CR>	


noremap <C-\> :copen<CR>
noremap \ :cnext<CR>
noremap \| :cp<CR>

 hi Pmenu        ctermfg=230  ctermbg=238  guifg=#ffffd7    guibg=#444444
 hi PmenuSel     ctermfg=232  ctermbg=192  guifg=#080808    guibg=#cae982
 highlight ColorColumn ctermbg='darkgrey'
