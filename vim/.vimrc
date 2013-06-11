set nocompatible
scriptencoding utf-8

" 動作環境識別変数 {{{

let s:w32 = has('win32')
let s:w64 = has('win64')
let s:osx = has('mac') || has('macunix')

" }}}

" 環境依存の設定 {{{

" 特定の環境の設定を読み込む
if filereadable($HOME . '/_vimrc.local')
  source $HOME/_vimrc.local
elseif filereadable($HOME . '/.vimrc.local')
  source $HOME/.vimrc.local
elseif filereadable($VIM . '/_vimrc.local')
  source $VIM/_vimrc.local
elseif filereadable($VIM . '/.vimrc.local')
  source $VIM/.vimrc.local
endif

" パス区切りをスラッシュに
if exists('+shellslash')
  set shellslash
endif

" }}}

" 端末のエンコーディング指定 {{{

if has('multi_byte') && !s:w32 && !s:w64 && !s:osx
  " 変数の値でsetする方法がわからない……
  "let s:system_encoding=matchstr($LANG, '\.\zs.*\ze$')
  "if s:system_encoding != ''
  "  set termencoding=&s:system_encoding
  "endif
  "unlet s:system_encoding
  if $LANG =~? '.UTF-8$'
    set encoding=utf-8
    set termencoding=utf-8
  endif
endif

" }}}

" neobundle.vim {{{

if has('vim_starting')
  set runtimepath+=~/.bundle/neobundle.vim
endif

call neobundle#rc(expand('~/.bundle'))

" }}}

" インストールするプラグイン {{{

NeoBundleFetch 'gh:Shougo/neobundle.vim.git'

" unite.vim {{{

NeoBundle 'gh:Shougo/unite.vim.git'
NeoBundle 'gh:Shougo/unite-outline.git'
NeoBundle 'gh:Shougo/unite-ssh.git'
NeoBundle 'gh:tsukkee/unite-tag.git'

" }}}

NeoBundle 'gh:Shougo/neocomplcache.git'

NeoBundle 'gh:Shougo/vimfiler.git', {
      \ 'depends' : 'gh:Shougo/unite.vim.git'
      \ }

NeoBundle 'gh:Shougo/vimproc.git', {
      \ 'build' : {
      \   'windows' : 'make -f make_mingw32.mak clean all',
      \   'cygwin' : 'make -f make_cygwin.mak clean all',
      \   'mac' : 'make -f make_mac.mak clean all',
      \   'unix' : 'make -f make_unix.mak clean all'
      \ }}

NeoBundle 'gh:Shougo/vimshell.git'

NeoBundle 'gh:Shougo/vinarise.git',
call neobundle#config('vinarise', {
      \ 'lazy': 1,
      \ 'autoload' : {
      \   'commands' : 'Vinarise',
      \ }})

NeoBundleLazy 'gh:thinca/vim-qfreplace.git', {
      \ 'autoload' : {
      \   'filetypes' : 'quickfix',
      \ }}

NeoBundle 'gh:thinca/vim-quickrun.git'
NeoBundle 'gh:thinca/vim-ref.git'

NeoBundleLazy 'gh:teramako/jscomplete-vim.git', {
      \ 'autoload' : {
      \   'filetypes' : 'javascript',
      \ }}

" syntax {{{

if isdirectory($GOROOT . '/misc')
  NeoBundleLocal $GOROOT/misc
endif

NeoBundle 'gh:jelera/vim-javascript-syntax.git'
NeoBundle 'gh:vim-scripts/JSON.vim.git'

NeoBundleLazy 'gh:digitaltoad/vim-jade.git', {
      \ 'autoload' : {
      \   'filetypes': 'jade',
      \ }}

NeoBundleLazy 'gh:jsx/jsx.vim.git', {
      \ 'autoload' : {
      \   'filetypes' : 'jsx',
      \ }}

NeoBundleLazy 'gh:kchmck/vim-coffee-script.git', {
      \ 'autoload' : {
      \   'filetypes' : 'coffee',
      \ }}

NeoBundleLazy 'gh:leafgarland/typescript-vim.git', {
      \ 'autoload' : {
      \   'filetypes' : 'typescript',
      \ }}

NeoBundleLazy 'gh:tpope/vim-markdown.git', {
      \ 'autoload' : {
      \   'filetypes' : 'markdown',
      \ }}

NeoBundleLazy 'gh:vim-scripts/delphi.vim.git', {
      \ 'autoload' : {
      \   'filetypes' : 'delphi',
      \ }}

" }}}

NeoBundle 'gh:mattn/gist-vim.git', {
      \   'depends' : 'gh:mattn/webapi-vim.git'
      \ }

NeoBundle 'gh:motemen/hatena-vim.git'

" TweetVim {{{

NeoBundle 'gh:basyura/TweetVim.git', {
      \ 'depends' : [
      \   'gh:basyura/twibill.vim.git',
      \   'gh:tyru/open-browser.vim.git',
      \   'gh:basyura/bitly.vim.git',
      \   'gh:h1mesuke/unite-outline.git',
      \   'gh:mattn/webapi-vim.git',
      \   'gh:Shougo/unite.vim.git',
      \ ]}

NeoBundle 'gh:yomi322/neco-tweetvim.git', {
      \   'depends' : [
      \     'gh:basyura/TweetVim.git',
      \     'gh:Shougo/neocomplcache.git'
      \   ]
      \ }
NeoBundle 'gh:yomi322/unite-tweetvim.git', {
      \   'depends' : [
      \     'gh:basyura/TweetVim.git',
      \     'gh:Shougo/unite.vim.git'
      \   ]
      \ }

" }}}

NeoBundleLazy 'gh:mattn/zencoding-vim.git', {
      \ 'autoload' : {
      \   'filetypes' : 'html',
      \ }}

NeoBundle 'gh:nathanaelkane/vim-indent-guides.git'
NeoBundle 'gh:othree/eregex.vim.git'
NeoBundle 'gh:scrooloose/syntastic.git'

NeoBundle 'gh:Lokaltog/vim-powerline.git', {
      \ 'gui': 1,
      \ }

filetype plugin on
filetype indent on

" インストールされているかチェックする
" インストールされていない場合はインストールをする
NeoBundleCheck

" }}}

" 検索とか {{{

set incsearch   " インクリメンタルサーチ
set ignorecase  " 大文字小文字を区別しない
set smartcase   " 検索文字列に大文字を含む場合は区別する
set wrapscan    " 最後まで検索したら先頭に戻る
set hlsearch    " 検索文字列をハイライトする

" }}}

" インデントとか {{{

set expandtab    " タブの代わりに半角スペースを挿入する
set smartindent  " 高度な自動インデント

set tabstop=2      " タブ幅
set softtabstop=0  " 機能無効
set shiftwidth=2   " インデント幅

" }}}

" ファイルタイプとか {{{

" *.binと*.exeと*.dllはxxd
autocmd BufNewFile,BufRead *.bin,*.exe,*.dll setlocal filetype=xxd

" *.asはJavaScript
autocmd BufNewFile,BufRead *.as setlocal filetype=javascript

" *.xulはXML
autocmd BufNewFile,BufRead *.xul setlocal filetype=xml

" CSS編集時のみタブにする
autocmd FileType css setlocal noexpandtab list tabstop=8 shiftwidth=8

" Makefile編集時のみタブにする
autocmd FileType make setlocal noexpandtab list tabstop=8 shiftwidth=8

" Python編集時のみインデントのスペース数を4にする
autocmd FileType python setlocal tabstop=4 shiftwidth=4

" }}}

" バッファとか {{{

set fileencoding=utf-8  " デフォルトの文字コード
set fileformat=unix     " デフォルトの改行コード

set nobackup   " バックアップファイルを作らない
set nobomb     " BOMを付加しない

set hidden  " バッファを閉じないで非表示にする

if has('kaoriya') && has('guess_encode')
  " 文字コードの自動判別
  set fileencodings=guess
else
  " 開いたファイルに合っているものを順番に試す
  set fileencodings=ucs-bom,utf-8,cp932,euc-jp,utf-16,utf-16le,iso-2022-jp
endif

" タブや改行などをを指定した記号で表示
" tab      タブ文字
" eol:     行末
" trail:   行末の半角スペース
" extends: 折り返しされた行の末尾
set listchars=tab:>.,eol:$,trail:_,extends:\

" バックスペースでいろいろ消せるように
set backspace=indent,eol,start

" 挿入モードを開始したときにペーストモードのキーバインドを設定する
autocmd InsertEnter * set pastetoggle=<C-e>

" 挿入モードから抜けるときにペーストモードを抜け、キーバインドも解除する
autocmd InsertLeave * set nopaste pastetoggle=

" }}}

" 表示とか {{{

syntax enable  " シンタックスハイライト

set number        " 行番号を表示する
set nowrap        " 折り返ししない
set showcmd       " コマンドを最下部に表示する
set shortmess+=I  " 起動時のメッセージを表示しない

" 折りたたみをインデントでする
set foldmethod=indent

" ステータスラインを常に表示する
set laststatus=2

" ステータスラインの表示を変更
set statusline=%n\:%y%F\ \|%{(&fenc!=''?&fenc:&enc).'\|'.(&ff=='dos'?'crlf':&ff=='mac'?'cr':'lf').'\|'}%m%r%=<%l:%v>

if exists('+vertsplit')
  " カレントウィンドウの右に分割する
  set splitright
endif

" }}}

" キーマップとか {{{

" 論理行でなく表示行で移動する
nnoremap j gj
vnoremap j gj

nnoremap k gk
vnoremap k gk

"nnoremap $ g$
"vnoremap $ g$

"nnoremap ^ g^
"vnoremap ^ g^

"nnoremap 0 g0
"vnoremap 0 g0

" diff系
nnoremap ,dg :<C-u>diffget<CR>
nnoremap ,do :<C-u>diffoff<CR>
nnoremap ,dO :<C-u>diffoff!<CR>
nnoremap ,dt :<C-u>diffthis<CR>
nnoremap ,du :<C-u>diffupdate<CR>

" F1を無効化
noremap <F1> <Nop>
noremap! <F1> <Nop>

" C-F4でバッファの削除
nnoremap <C-F4> :<C-u>bdelete<CR>

" C-Tab, C-S-Tabでバッファの移動
nnoremap <C-Tab> :<C-u>bnext<CR>
nnoremap <C-S-Tab> :<C-u>bprevious<CR>

" }}}

" その他 {{{

" 日本語のヘルプを優先して表示する
set helplang=ja,en

" ファイルパスなどを最長補完して全てのマッチを表示する
set wildmode=list:longest

" tagsファイルを上位のディレクトリにさかのぼって検索する
set tags+=./tags;

" diffsplitは常に垂直分割する
set diffopt+=vertical

if s:w32 || s:w64
  " grepコマンドでvimgrepを使用する
  set grepprg=internal
else
  " 外部grepを使用する場合の設定
  set grepprg=grep\ -niEH
endif

" }}}

" プラグインの設定とか {{{

" delphi.vim {{{

" *.dprと*.lprと*.pasと*.ppはDelphi
autocmd BufNewFile,BufRead *.dpr,*.lpr,*.pas,*.pp setlocal filetype=delphi

" }}}

" gist-vim {{{

" 複数ファイルを取得する
let g:gist_get_multiplefile = 1

nnoremap ,gd :<C-u>Gist -d<CR>
nnoremap ,ge :<C-u>Gist -s<Space>
nnoremap ,gf :<C-u>Gist -f<CR>
nnoremap ,gl :<C-u>Gist -l<CR>
nnoremap ,gmp :<C-u>Gist -m -p -s<Space>
nnoremap ,gmP :<C-u>Gist -m -P -s<Space>
nnoremap ,gp :<C-u>Gist -p -s<Space>
nnoremap ,gP :<C-u>Gist -P -s<Space>

" }}}

" Go言語 {{{

" *.goはGo
autocmd BufNewFile,BufRead *.go setlocal filetype=go

" Go編集時はタブにする
autocmd FileType go setlocal noexpandtab list tabstop=2 shiftwidth=2

" }}}

" hatena-vim {{{

" ユーザー名
let g:hatena_user = 'sasaplus1'

" 保存してもすぐに投稿しない
let g:hatena_upload_on_write = 0

" :w!でアップデートする
let g:hatena_upload_on_write_bang = 1

" 一時ファイル名
let g:hatena_entry_file = '~/hatena_entry_file.htn'

" *.htnはhatena
autocmd BufNewFile,BufRead *.htn setlocal filetype=hatena

" }}}

" jscomplete-vim {{{

" DOM系の補完リスト、Mozilla JavaScriptの追加リスト
let g:jscomplete_use = ['dom', 'moz', 'es6th']

" ファイルタイプがJavaScriptの場合に有効化
autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS

" }}}

" JSX {{{

" *.jsxはjsx
autocmd BufNewFile,BufRead *.jsx setlocal filetype=jsx

" }}}

" neocomplcache {{{

" 候補が1つだけの場合もポップアップメニューを表示する
set completeopt+=menuone

" neocomplcacheを有効にする
let g:neocomplcache_enable_at_startup=1

" 入力に大文字を含む場合、大/小文字を無視しない
let g:neocomplcache_enable_smart_case=1

" キャメルケースの補完を有効にする
let g:neocomplcache_enable_camel_case_completion=1

" アンダースコアの補完を有効にする
let g:neocomplcache_enable_underbar_completion=1

" neocomplcacheがインストールされている場合
if neobundle#is_installed('neocomplcache')

  " *neocomplcache-examples* よりキーマップの変更
  inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

  " Vim標準の補完をneocomplcacheのものに置き換える
  " http://vim-users.jp/2009/10/hack89/
  inoremap <expr><C-x><C-f>  neocomplcache#manual_filename_complete()
  inoremap <expr><C-j>  &filetype == 'vim' ? "\<C-x>\<C-v>\<C-p>" : neocomplcache#manual_omni_complete()

endif

" }}}

" neobundle {{{

" ログを出力する
let g:neobundle_log_filename = expand('~/.bundle/neobundle.log')

" ,ncでNeoBundleCleanを実行
nnoremap ,nc :<C-u>NeoBundleClean<CR>

" ,niでneobundle/installソースを実行
nnoremap ,ni :<C-u>Unite neobundle/install:!<CR>

" ,nuでneobundle/updateソースを実行
nnoremap ,nu :<C-u>Unite neobundle/update -auto-quit<CR>

" }}}

" ref {{{

" ,rmでmanをuniteで検索
nnoremap ,rm :<C-u>Unite ref/man<CR>

" }}}

" smartchr {{{

"autocmd FileType javascript inoremap <buffer> <expr> -> smartchr#one_of('function', '->')

" }}}

" syntastic {{{

" 保存時・チェック時にチェックする言語の指定
let g:syntastic_mode_map = { 'mode': 'active',
      \ 'active_filetypes': [],
      \ 'passive_filetypes': ['javascript'] }

" エラーが発生したときにQuickfixが表示されるように
let g:syntastic_auto_loc_list = 1

" JavaScriptのチェックにgjslintを使用する
let g:syntastic_javascript_checker = 'gjslint'

" gjslintで使用するオプションを指定する
let g:syntastic_javascript_gjslint_conf = '--strict --nojsdoc'

" ,scで構文チェック
nnoremap ,sc :<C-u>SyntasticCheck<CR>

" }}}

" TweetVim {{{

" 1ページに表示する最大数
let g:tweetvim_tweet_per_page = 50

" クライアント名を表示する
let g:tweetvim_display_source = 1

" ツイートした時刻を表示する
let g:tweetvim_display_time = 1

" F6と,uvでTweetVimのtimeline選択
nnoremap <F6> :<C-u>Unite tweetvim<CR>
nnoremap ,uv :<C-u>Unite tweetvim<CR>

" S-F6でTwitter検索
nnoremap <S-F6> :<C-u>Unite tweetvim/search_new<CR>

" その他いろいろ
nnoremap ,th :<C-u>TweetVimHomeTimeline<CR>
nnoremap ,tm :<C-u>TweetVimMentions<CR>
nnoremap ,ts :<C-u>TweetVimSay<CR>
nnoremap ,tc :<C-u>TweetVimCommandSay<Space>
nnoremap ,tr :<C-u>TweetVimSearch<Space>
nnoremap ,tu :<C-u>TweetVimUserTimeline<Space>

" }}}

" typescript-vim {{{

" *.tsはtypescript
autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript

" }}}

" unite.vim {{{

" ウィンドウの高さを変更する
let g:unite_winheight=15

" unite-grepのオプションを変更する
" --line-number --ignore-case --extended-regexp --with-filename
let g:unite_source_grep_default_opts='-niEH'

" unite-history/yankを有効化
let g:unite_source_history_yank_enable=1

" F2と,ubでバッファ一覧
nnoremap <F2> :<C-u>Unite buffer<CR>
nnoremap ,ub :<C-u>Unite buffer<CR>

" Ctrl-F2と,umで最近開いたファイル一覧
nnoremap <C-F2> :<C-u>Unite file_mru<CR>
nnoremap ,um :<C-u>Unite file_mru<CR>

" ,ugでgrep
nnoremap ,ug :<C-u>Unite grep<CR>

" Shift-F2と,uoでアウトライン一覧
nnoremap <S-F2> :<C-u>Unite outline<CR>
nnoremap ,uo :<C-u>Unite outline<CR>

" F3と,utでtagsの一覧を開く
nnoremap <F3> :<C-u>Unite tag<CR>
nnoremap ,ut :<C-u>Unite tag<CR>

" Shift-F3と,uwでカーソル位置の単語をtagsから調べて飛ぶ
nnoremap <S-F3> :<C-u>UniteWithCursorWord -immediately tag<CR>
nnoremap ,uw :<C-u>UniteWithCursorWord -immediately tag<CR>

" ,ufでバッファディレクトリのファイルとディレクトリの一覧
nnoremap ,uf :<C-u>UniteWithBufferDir file<CR>

" ,uyでヤンク履歴の一覧
nnoremap ,uy :<C-u>Unite history/yank<CR>

" ,uaでマッピングの一覧
nnoremap ,ua :<C-u>Unite mapping<CR>

" カレントディレクトリからファイルの一覧などを表示
nnoremap <C-p> :<C-u>execute
      \ 'Unite'
      \ '-start-insert'
      \ 'buffer file_mru'
      \ 'file:'.fnameescape(expand('%:p:h'))
      \ 'file_rec:!:'.fnameescape(expand('%:p:h'))
      \ <CR>

" }}}

" vim-coffee-script {{{

" *.coffeeはcoffee
autocmd BufNewFile,BufRead *.coffee setlocal filetype=coffee

" }}}

" vim-indent-guides {{{

" インデントガイドの太さを1にする
let g:indent_guides_guide_size = 1

" 2レベル目のインデントからガイドを表示する
let g:indent_guides_start_level = 2

" ,itでインデントガイドの表示・非表示を切り替える
nnoremap ,it :<C-u>IndentGuidesToggle<CR>

" }}}

" vim-markdown {{{

" *.md,*.markdown,*.mkd,*.mdown,*.mkdn,*.markはmarkdown
autocmd BufNewFile,BufRead *.md,*.markdown,*.mkd,*.mdown,*.mkdn,*.mark setlocal filetype=markdown

" }}}

" vim-powerline {{{

" スペシャルシンボルを使わない
let g:Powerline_symbols = 'compatible'

" シンボルを上書きする
let g:Powerline_symbols_override = {
      \ 'LINE': 'Caret'
      \ }

" モード名を上書きする
let g:Powerline_mode_n = 'Normal'
let g:Powerline_mode_i = 'Insert'
let g:Powerline_mode_R = 'Replace'
let g:Powerline_mode_v = 'Visual'
let g:Powerline_mode_V = 'Visual-Line'
let g:Powerline_mode_cv = 'Visual-Block'
let g:Powerline_mode_s = 'Select'
let g:Powerline_mode_S = 'Select-Line'
let g:Powerline_mode_cs = 'Select-Block'

" ファイルへの相対パスを表示する
let g:Powerline_stl_path_style = 'relative'

" }}}

" VimFiler {{{

" デフォルトのファイラにする
let g:vimfiler_as_default_explorer=1

" F4と,vfで表示
nnoremap <F4> :<C-u>VimFilerBufferDir<CR>
nnoremap ,vf :<C-u>VimFilerBufferDir<CR>

" Shift-F4と,vFでエクスプローラ風の表示
nnoremap <S-F4> :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>
nnoremap ,vF :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>

" }}}

" VimShell {{{

" 大文字が入力された場合のみ大文字小文字を無視しない
let g:vimshell_smart_case=1

" プロンプトの上部にカレントディレクトリを表示する
let g:vimshell_user_prompt='getcwd()'

" プロンプトの表示を変更する
if s:w32 || s:w64
  let g:vimshell_prompt=$USERNAME.'@'.$USERDOMAIN.'$ '
else
  let g:vimshell_prompt=$USER.'@'.system('echo -n `hostname -s`').'$ '
endif

" シェルを起動する端末プログラムを指定する
if s:w32 || s:w64
  let g:vimshell_use_terminal_command='cmd.exe /C'
else
  let g:vimshell_use_terminal_command='sh -e'
endif

" F5と,vsで横分割表示
nnoremap <F5> :<C-u>VimShellBufferDir -popup<CR>
nnoremap ,vs :<C-u>VimShellBufferDir -popup<CR>

" Shift-F5と,vSで縦分割表示
nnoremap <S-F5> :<C-u>VimShellBufferDir -split<CR>
nnoremap ,vS :<C-u>VimShellBufferDir -split<CR>

" }}}

" ZenCoding {{{

" 各種設定など
let g:user_zen_settings = {
      \  'charset' : 'utf-8',
      \  'lang' : 'ja',
      \  'locale' : 'ja-JP',
      \  'html' : {
      \    'indentation' : '  ',
      \    'snippets' : {
      \      'html:5' : "<!DOCTYPE html>\n"
      \               . "<html lang=\"${lang}\">\n"
      \               . "<head>\n"
      \               . "    <meta charset=\"${charset}\">\n"
      \               . "    <title></title>\n"
      \               . "</head>\n"
      \               . "<body>\n  ${child}|\n</body>\n"
      \               . "</html>",
      \      'html:5s' : "<!DOCTYPE html>\n"
      \                . "<meta charset=\"${charset}\">\n"
      \                . "<title>${child}|</title>\n"
      \    }
      \  }
      \}

" }}}

" }}}

set secure

" vim:ft=vim:fdm=marker:fen:
