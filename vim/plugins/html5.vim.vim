scriptencoding utf-8

if !exists('*dein#add') || has('nvim')
  finish
endif

" *.ejsと*.vueのファイルタイプをHTMLとする
autocmd vimrc BufNewFile,BufRead *.{ejs,vue} setlocal filetype=html

call dein#add('othree/html5.vim', {
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'merge_ftdetect' : 1,
      \ 'on_ft' : ['html', 'php'],
      \ })

" vim:ft=vim:fdm=marker:fen:
