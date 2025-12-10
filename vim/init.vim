scriptencoding utf-8

" グループの初期化
augroup vimrc
  autocmd!
augroup END

" ランタイムパスの初期化
set runtimepath&

" コマンドを持っているかどうかを確認する
function! s:has_commands(commands)
  return empty(filter(a:commands, '!executable(v:val)'))
endfunction

" 設定ファイルなどのディレクトリ
let g:vimrc_vim_dir = has('nvim') ? expand('~/.nvim') : expand('~/.vim')

" node.js {{{

" renovate: datasource=github-tags depName=nodejs/node
let s:node_version = 'v24.0.1'

" プラグインが使用するnode.jsのパス
let s:node_bin = simplify(g:vimrc_vim_dir . '/node/bin/node')
let s:node_dir = fnamemodify(s:node_bin, ':h:h')
let s:node_ver = substitute(s:node_version, '^v', '', '')

" プラグインが使用するnode.jsをインストールする
" TODO: シェルスクリプトに移した方が良さそう
function! s:install_node() abort
  " 必要なコマンドが存在しない場合は何もしない
  if !s:has_commands(['curl', 'tar', 'uname'])
    return
  endif

  let info = trim(system('uname -ms'))
  let os = info =~? '\vDarwin' ? 'darwin' : info =~? '\vLinux' ? 'linux' : ''
  let arch = info =~? '\varm64|aarch64' ? 'arm64' : info =~? '\vx86_64' ? 'x64' : ''

  if empty(os) || empty(arch)
    return
  endif

  call mkdir(s:node_dir, 'p')

  let script = printf(
        \ 'curl -fsSL "https://nodejs.org/download/release/v%s/node-v%s-%s-%s.tar.gz" | ' .
        \ 'tar fx - -C "%s" --strip-components 1',
        \ s:node_ver, s:node_ver, os, arch, s:node_dir,
        \ )

  execute '!' . script
endfunction

" プラグインが使用するnode.jsが存在しない場合はインストールする
if empty(glob(s:node_bin))
  call s:install_node()
endif

" パスを通す
let $PATH = fnamemodify(s:node_bin, ':h') . ':' . $PATH

" }}}

" deno {{{

" renovate: datasource=github-tags depName=denoland/deno
let s:deno_version = 'v2.6.0'

" プラグインが使用するnode.jsのパス
let s:deno_bin = simplify(g:vimrc_vim_dir . '/deno/bin/deno')
let s:deno_dir = fnamemodify(s:deno_bin, ':h')
let s:deno_ver = substitute(s:deno_version, '^v', '', '')

" プラグインが使用するdenoをインストールする
function! s:install_deno() abort
  " 必要なコマンドが存在しない場合は何もしない
  if !s:has_commands(['curl', 'uname', 'unzip'])
    return
  endif

  let info = trim(system('uname -ms'))
  let os = info =~? '\vDarwin' ? 'apple-darwin' : info =~? '\vLinux' ? 'unknown-linux' : ''
  let arch = info =~? '\varm64|aarch64' ? 'aarch64' : info =~? '\vx86_64' ? 'x86_64' : ''

  if empty(os) || empty(arch)
    return
  endif

  call mkdir(s:deno_dir, 'p')

  let script = printf(
        \ 'curl -fsSL "https://github.com/denoland/deno/releases/download/v%s/deno-%s-%s.zip" -o "%s/deno.zip" && ' .
        \ 'unzip "%s/deno.zip" -d "%s" && ' .
        \ 'command rm %s/deno.zip',
        \ s:deno_ver, arch, os, s:deno_dir, s:deno_dir, s:deno_dir, s:deno_dir,
        \ )

  execute '!' . script
endfunction

" プラグインが使用するdenoが存在しない場合はインストールする
if empty(glob(s:deno_bin))
  call s:install_deno()
endif

" パスを通す
let $PATH = fnamemodify(s:deno_bin, ':h') . ':' . $PATH

" }}}

" vim:ft=vim:fdm=marker:fen:
