scriptencoding utf-8

" グループの初期化
augroup vimrc
  autocmd!
augroup END

" ランタイムパスの初期化
set runtimepath&

" 設定ファイルなどのディレクトリ
let g:vimrc_vim_dir = has('nvim') ? expand('~/.nvim') : expand('~/.vim')

" vim:ft=vim:fdm=marker:fen:
