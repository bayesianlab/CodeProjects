map <F10> :NERDTree<CR>
nmap <c-S> :source ~/.vimrc<CR>

nmap pf idef<space>(<esc>i
nmap pm i<space><space><space><space>def<space>(self<esc>4hi
nmap pc iclass<space>(<esc>i

imap <c-L> <esc>f(a
imap ( ()<left>

inoremap {<CR> {<CR>} <Esc>ko
map , <Plug>(easymotion-prefix)
map <,> <Plug>(easymotion-prefix)
map <F8> :w <CR> :!gcc % -o %< && ./%< <CR>
nmap %d iprintf("%d\n"<esc>f)a; 
