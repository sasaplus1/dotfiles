" NOTE:
"   see: :help no-eval-feature
"   see: https://stackoverflow.com/questions/27451637/what-is-1-testing-against-in-if-1-finish-in-a-vimscript
if 1
  " symlink先のファイルパスを解決
  let s:vimrc_file = resolve($MYVIMRC)
  " ファイル名を取り除く
  let s:vimrc_dir = fnamemodify(s:vimrc_file, ':h')

  execute 'source' s:vimrc_dir . '/.vimrc.root'

  unlet s:vimrc_dir
  unlet s:vimrc_file
endif

" vim:ft=vim:fdm=marker:fen:
