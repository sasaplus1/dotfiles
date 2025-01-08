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
let s:node_bin = simplify(g:vimrc_vim_dir . '/node/bin/node')
let s:node_dir = fnamemodify(s:node_bin, ':h:h')
let s:node_ver = '22.12.0'

" プラグインが使用するnode.jsをインストールする
" TODO: シェルスクリプトに移した方が良さそう
function! s:install_node() abort
  let commands = ['curl', 'tar', 'uname']
  
  if commands->map('executable(v:val) ? 0 : 1')->filter('v:val != 0')->len() > 0
    return
  endif

  if has('osxdarwin')
    let platform = 'darwin'
  elseif has('linux')
    let platform = 'linux'
  else
    return
  endif

  let uname = trim(system('uname -m'))

  if uname =~# '\v^(arm64|aarch64)$'
    let arch = 'arm64'
  elseif uname ==# 'x86_64'
    let arch = 'x64'
  else
    return
  endif

  call mkdir(s:node_dir, 'p')

  let script = printf(
        \ 'curl -fsSL "https://nodejs.org/download/release/v%s/node-v%s-%s-%s.tar.gz" | ' .
        \ 'tar fx - -C "%s" --strip-components 1',
        \ s:node_ver, s:node_ver, platform, arch, s:node_dir,
        \ )

  execute '!' . script
endfunction

" プラグインが使用するnode.jsが存在しない場合はインストールする
if empty(glob(s:node_bin))
  call s:install_node()
endif

" パスを通す
let $PATH = fnamemodify(s:node_bin, ':h') . ':' . $PATH

" vim:ft=vim:fdm=marker:fen:
