" othree/html5.vim {{{
function! s:hook_add_html5_vim() abort
  " *.ejsと*.vueのファイルタイプをHTMLとする
  autocmd vimrc BufNewFile,BufRead *.{ejs,vue} setlocal filetype=html
endfunction

call dein#add('othree/html5.vim', {
      \ 'hook_add' : function('s:hook_add_html5_vim'),
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'on_ft' : [
      \   'html',
      \   'php',
      \ ],
      \ })
" }}}


