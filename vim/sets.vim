scriptencoding utf-8

" 改行コードをLFにする
set fileformat=unix

" defaults.vimで設定される値を上書きする
set scrolloff=0

" 日本語のヘルプを優先して表示する
set helplang=ja,en

" ファイルパスなどを最長補完して全てのマッチを表示する
set wildmode=list:longest

" tagsファイルを上位のディレクトリにさかのぼって検索する
set tags&
set tags+=./tags;

set incsearch      " インクリメンタルサーチ
set ignorecase     " 大文字小文字を区別しない
set smartcase      " 検索文字列に大文字を含む場合は区別する
set wrapscan       " 最後まで検索したら先頭に戻る
set hlsearch       " 検索文字列をハイライトする
set expandtab      " タブの代わりに半角スペースを挿入する
set tabstop=2      " タブ幅
set softtabstop=0  " 機能無効
set shiftwidth=2   " インデント幅
set nobomb         " BOMを付加しない
set hidden         " バッファを閉じないで非表示にする

" 候補が1つだけの場合もポップアップメニューを表示する
set completeopt&
set completeopt+=menuone,noinsert,noselect

" プレビューウィンドウを表示しない
set completeopt-=preview

" タブや改行などをを指定した記号で表示
" tab      タブ文字
" eol:     行末
" trail:   行末の半角スペース
" extends: 折り返しされた行の末尾
set listchars=tab:>.,eol:$,trail:_,extends:\

" バックスペースでいろいろ消せるように
set backspace=indent,eol,start

set number        " 行番号を表示する
set nowrap        " 折り返ししない
set showcmd       " コマンドを最下部に表示する

" 起動時のメッセージを表示しない
set shortmess&
set shortmess+=I

set ttyfast      " 高速ターミナル接続を行なう
"set lazyredraw  " キーボードから実行されないコマンドの実行で再描画しない

" 対応する括弧のハイライトを0.1秒にする
set matchtime=1

" <と>も強調表示対象に入れる
set matchpairs&
set matchpairs+=<:>

" 対応する開き括弧にわずかな時間ジャンプする
set showmatch

set diffopt&
set diffopt+=vertical  " diffsplitは常に垂直分割する
" set diffopt+=iwhite  " diffの空白を無視する

" マウス操作を受け付けない
set mouse=

" ステータスラインを常に表示する
set laststatus=2

" コマンドラインの高さを2にする
set cmdheight=2

if has('statusline')
  " ステータスラインの表示を変更
  set statusline=%n\:%y%F\ \|%{(&fenc!=''?&fenc:&enc).'\|'.(&ff=='dos'?'crlf':&ff=='mac'?'cr':'lf').'\|'}%m%r%=<%l:%v>
endif

" 256色にする
" https://stackoverflow.com/a/15378816
if !has('gui_running') && &term ==# 'screen'
  set t_Co=256
endif

if has('smartindent')
  " 高度な自動インデント
  set smartindent
endif

if has('syntax')
  " シンタックスハイライトを300桁までに制限する
  set synmaxcol=300
endif

if exists('multi_byte')
  " 一部の全角文字を全角の幅で扱う
  set ambiwidth=double
endif

" 折りたたみをインデントでする
" if has('folding')
"   set foldmethod=indent
" endif

" vimgrepなどでディレクトリやファイルを除外する
if has('wildignore')
  set wildignore&
  " ディレクトリ
  set wildignore+=bower_components/**
  set wildignore+=node_modules/**
  set wildignore+=vendor/**
  " ドットから始まるディレクトリ
  set wildignore+=.git/**
  set wildignore+=.hg/**
  set wildignore+=.svn/**
  set wildignore+=.bundle/**
  set wildignore+=.sass-cache/**
  set wildignore+=.node-gyp/**
  set wildignore+=.cache/**
  " ファイル
  set wildignore+=*.exe,*.so,*.dll
  set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.webp,*.ai,*.psd
endif

" バッファのディレクトリをカレントディレクトリにする
" if exists('+autochdir')
"   set autochdir
" endif

if exists('+shellslash')
  set shellslash
endif

if has('vertsplit')
  " カレントウィンドウの右に分割する
  set splitright
endif

if has('guess_encode')
  " 文字コードの自動判別
  set fileencodings=guess,ucs-bom,iso-2022-jp-3,utf-8,euc-jp,cp932
elseif has('multi_byte')
  " 開いたファイルに合っているものを順番に試す

  " https://github.com/Shougo/shougo-s-github/blob/b12435cdded41c7d77822b2a0a97beeab09b8d2c/vim/rc/init.rc.vim#L28-L29
  " set fileencodings=ucs-bom,iso-2022-jp-3,utf-8,euc-jp,cp932

  " http://www.tooyama.org/vim-2.html
  " set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8

  " https://ravelll.hatenadiary.jp/entry/2015/08/20/140710
  " set fileencodings=utf-8,euc-jp,sjis,cp932,iso-2022-jp

  " 順番的にこれでないと解析できないが、マルチバイトのないファイルでのコードがiso-2022-jpになってしまう
  " set fileencodings=iso-2022-jp,ucs-bom,utf-8,euc-jp,cp932,default,latin1

  " encodingの値がUnicodeに設定された時のデフォルトの値を指定する
  set fileencodings=ucs-bom,utf-8,default,latin1
endif

if exists('+fixendofline')
  " 改行コードを勝手に付加しない
  set nofixendofline
endif

if executable('rg')
  " rgコマンドを使用する場合の設定
  set grepprg=rg\ --hidden\ --no-heading\ --smart-case\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('pt')
  " ptコマンドを使用する場合の設定
  set grepprg=pt\ --nocolor\ --nogroup\ --smart-case
elseif has('win32') || has('win64')
  " grepコマンドでvimgrepを使用する
  set grepprg=internal
else
  " 外部grepを使用する場合の設定
  set grepprg=grep\ -inrEH
endif

if executable('locale') && system('locale -a') =~# 'ja_JP.UTF-8'
  " 表示を日本語にする
  language ja_JP.UTF-8
endif

" mkdir関数が存在する場合
if exists('*mkdir')
  " バックアップファイルの保存先を変更 {{{
  let backupdir = simplify(g:vimrc_vim_dir . '/backup')

  if empty(glob(backupdir))
    call mkdir(backupdir, 'p')
  endif

  execute 'set' 'backupdir=' . backupdir
  set backupdir+=.
  set backupdir+=~/tmp
  set backupdir+=~/
  " }}}

  " スワップファイルの保存先を変更 {{{
  let swapdir = simplify(g:vimrc_vim_dir . '/swap')

  if empty(glob(swapdir))
    call mkdir(swapdir, 'p')
  endif

  execute 'set' 'directory=' . swapdir
  set directory+=.
  set directory+=~/tmp
  set directory+=/var/tmp
  set directory+=/tmp
  " }}}

  " アンドゥファイルの保存先を指定する {{{
  let undodir = simplify(g:vimrc_vim_dir . '/undo')

  if empty(glob(undodir))
    call mkdir(undodir, 'p')
  endif

  if has('persistent_undo')
    set undofile

    execute 'set' 'undodir=' . undodir
    set undodir+=.
    set undodir+=~/tmp
    set undodir+=~/
  endif
  " }}}
endif

" vim:ft=vim:fdm=marker:fen:
