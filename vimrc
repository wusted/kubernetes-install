syntax on
filetype plugin indent on

"2 space indentation"
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

set is hlsearch ai ic scs
nnoremap <esc><esc> :nohls<cr>

"https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
