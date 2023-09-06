scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

function! s:hook_add_html5_vim() abort
  " *.ejsと*.vueのファイルタイプをHTMLとする
  autocmd vimrc BufNewFile,BufRead *.{ejs,vue} setlocal filetype=html
endfunction

call dein#add('othree/html5.vim', {
      \ 'hook_add' : function('s:hook_add_html5_vim'),
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : [
      \   'html',
      \   'php',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
