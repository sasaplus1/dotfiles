set nocompatible
scriptencoding utf-8

" 動作環境識別変数 {{{

let s:w32 = has('win32')
let s:w64 = has('win64')
let s:osx = has('mac') || has('macunix') || has('gui_mac') || has('gui_macvim')

" }}}

" vimrcの設定を読み込む {{{

if filereadable($HOME . '/_vimrc')
  source $HOME/_vimrc
elseif filereadable($HOME . '/.vimrc')
  source $HOME/.vimrc
elseif filereadable($VIM . '/_vimrc')
  source $VIM/_vimrc
elseif filereadable($VIM . '/.vimrc')
  source $VIM/.vimrc
endif

" }}}

" フォントとか {{{

if s:w32 || s:w64
  set guifont=Ricty:h12:b:cSHIFTJIS
  set guifont+=MS_Gothic:h10:cSHIFTJIS
  set guifontwide=Ricty:h12:b:cSHIFTJIS
  set guifontwide+=MS_Gothic:h10:cSHIFTJIS
elseif s:osx
  set guifont=Ricty\ Regular:h14,Menlo\ Regular:h11
  set guifontwide=Ricty\ Regular:h14,Menlo\ Regular:h11
else
  set guifont=Ricty\ 12,DejaVu\ Sans\ Mono\ 8
  set guifontwide=Ricty\ 12,VL\ ゴシック\ 8
endif

" }}}

" 表示とか {{{

" ツールバーを非表示にする
set guioptions-=T

" 全角スペースに下線を引く
augroup highlightZenkakuSpace
  autocmd ColorScheme * highlight ZenkakuSpace cterm=underline ctermfg=lightblue gui=underline guifg=lightblue
  autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END

" darkblueカラースキームにする
colorscheme darkblue

if (s:w32 || s:w64) && has('multi_byte_ime')
  " IMEがONになったらキャレットの色を変える
  highlight CursorIM guifg=bg guibg=Green gui=NONE
endif

if s:osx
  set imdisable        " IMを自動でオン/オフしない
  set showtabline=0    " タブを表示しない
  set fuopt+=maxhorz   " フルスクリーン時に横幅を最大にする
  set transparency=20  " 背景を透過させる
endif

" }}}

" vim:ft=vim:fdm=marker:fen:
