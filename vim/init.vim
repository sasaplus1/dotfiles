scriptencoding utf-8

" グループの初期化
augroup vimrc
  autocmd!
augroup END

" ランタイムパスの初期化
set runtimepath&

" 設定ファイルなどのディレクトリ
let g:vimrc_vim_dir = has('nvim') ? expand('~/.nvim') : expand('~/.vim')

" プラグインが使用するnode.jsのパス
let s:node = simplify(g:vimrc_vim_dir . '/node/bin/node')

" プラグインが使用するnode.jsをインストールする
" TODO: シェルスクリプトに移した方が良さそう
function! s:install_node() abort
  if !executable('uname') || !executable('curl')
    return
  endif

  let ver = '20.12.2'

  if has('osxdarwin')
    let platform = 'darwin'
  elseif has('linux')
    let platform = 'linux'
  endif

  let uname = trim(system('uname -m'))

  if uname =~# '\v^(arm64|aarch64)$'
    let arch = 'arm64'
  elseif uname ==# 'x86_64'
    let arch = 'x64'
  endif

  let url = printf(
        \ 'https://nodejs.org/download/release/v%s/node-v%s-%s-%s.tar.gz',
        \ ver,
        \ ver,
        \ platform,
        \ arch,
        \ )

  let dir = fnamemodify(s:node, ':h:h')

  call mkdir(dir, 'p')

  let tgz = simplify(g:vimrc_vim_dir . '/node.tar.gz')

  let curl = printf(
        \ 'curl -fsSL -o "%s" "%s"',
        \ tgz,
        \ url,
        \ )
  let tar = printf(
        \ 'tar fx "%s" -C "%s" --strip-components 1',
        \ tgz,
        \ dir,
        \ )

  call system(curl)
  call system(tar)
endfunction

" プラグインが使用するnode.jsが存在しない場合はインストールする
if empty(glob(s:node))
  call s:install_node()
endif

" パスを通す
let $PATH = fnamemodify(s:node, ':h') . ':' . $PATH

" vim:ft=vim:fdm=marker:fen:
