" 動作環境識別変数 {{{

let s:w32 = has('win32')
let s:w64 = has('win64')
let s:osx = has('mac') || has('macunix')

let s:pt = executable('pt')

" }}}

" エンコーディング指定 {{{

if has('multi_byte') && !s:w32 && s:w64
  set encoding=utf-8
endif

scriptencoding utf-8

" }}}

" グループの初期化 {{{

augroup vimrc
  autocmd!
augroup END

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

" ターミナルで起動した場合に256色にする
if !has('gui_running')
  set t_Co=256
endif

" }}}

" neobundle.vim {{{

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
endif

call neobundle#begin()

" }}}

" インストールするプラグイン {{{

" neobundle.vim {{{

NeoBundleFetch 'gh:Shougo/neobundle.vim.git'

" ログを出力する
let g:neobundle_log_filename = expand('~/.vim/bundle/neobundle.log')

" ,ncでNeoBundleCleanを実行
nnoremap ,nc :<C-u>NeoBundleClean<CR>

" ,niでneobundle/installソースを実行
nnoremap ,ni :<C-u>Unite neobundle/install:!<CR>

" ,nuでneobundle/updateソースを実行
nnoremap ,nu :<C-u>Unite neobundle/update -auto-quit<CR>

" }}}

" vimproc.vim {{{

NeoBundle 'gh:Shougo/vimproc.vim.git', {
      \ 'build' : {
      \   'windows' : 'tools\\update-dll-mingw',
      \   'cygwin' : 'make -f make_cygwin.mak',
      \   'mac' : 'make',
      \   'linux' : 'make',
      \   'unix' : 'gmake',
      \ },
      \ }

" }}}

" unite.vim {{{

NeoBundleLazy 'gh:Shougo/unite.vim.git', {
      \ 'pre_cmd' : 'Unite'
      \ }

let s:bundle = neobundle#get('unite.vim')
function! s:bundle.hooks.on_source(bundle)
  " デフォルトの設定
  "   ウィンドウの高さを変更する
  "   デフォルトで挿入モードにする
  call unite#custom#profile('default', 'context', {
        \ 'winheight' : 15,
        \ 'start_insert' : 1,
        \ })

  " grepとfile_rec/*でファイルやディレクトリを無視する
  call unite#custom#source(
        \ 'grep,file_rec/async,file_rec/git',
        \ 'ignore_pattern',
        \ join([
        \   'vendor/bundle',
        \   '.bundle/',
        \   '.sass-cache/',
        \   '.node-gyp/',
        \   'node_modules/',
        \   'bower_components/',
        \   '\.\(bmp\|gif\|jpe\?g\|png\|webp\|ai\|psd\)"\?$',
        \   '\.min\.',
        \ ], '\|'),
        \ )

  " directory_*でディレクトリを無視する
  call unite#custom#source(
        \ 'directory_mru,directory_rec/async',
        \ 'ignore_pattern',
        \ join([
        \   'vendor/bundle',
        \   '.bundle/',
        \   '.sass-cache/',
        \   '.node-gyp/',
        \   'node_modules/',
        \   'bower_components/',
        \ ], '\|'),
        \ )
endfunction
unlet s:bundle

" ptが使用できる場合ptを使用してgrepする
if s:pt
  let g:unite_source_grep_command='pt'
  let g:unite_source_grep_default_opts='--nocolor --nogroup --smart-case'
  let g:unite_source_grep_recursive_opt=''
  " NOTE:
  "   ファイル名・ディレクトリ名の列挙だけならfindの方が速い
  "   directory_rec/asyncで2回目以降にファイル名も混在してしまう
  " let g:unite_source_rec_async_command='pt --nocolor --nogroup -g .'
else
  " unite-grepのオプションを変更する
  " --line-number --ignore-case --extended-regexp --with-filename
  let g:unite_source_grep_default_opts='-niEH'
endif

" F2と,ubでバッファ一覧
nnoremap <F2> :<C-u>Unite buffer<CR>
nnoremap ,ub :<C-u>Unite buffer<CR>

" ,ugでgrep
nnoremap ,ug :<C-u>Unite grep<CR>

" ,ulで行一覧
nnoremap ,ul :<C-u>Unite line<CR>

" Shift-F2と,uoでアウトライン一覧
nnoremap <S-F2> :<C-u>Unite -no-start-insert outline<CR>
nnoremap ,uo :<C-u>Unite -no-start-insert outline<CR>

" F3と,utでtagsの一覧を開く
nnoremap <F3> :<C-u>Unite -no-start-insert tag<CR>
nnoremap ,ut :<C-u>Unite -no-start-insert tag<CR>

" Shift-F3と,uwでカーソル位置の単語をtagsから調べて飛ぶ
nnoremap <S-F3> :<C-u>UniteWithCursorWord -no-start-insert -immediately tag<CR>
nnoremap ,uw :<C-u>UniteWithCursorWord -no-start-insert -immediately tag<CR>

" ,ufでバッファディレクトリのファイルとディレクトリの一覧
nnoremap ,uf :<C-u>UniteWithBufferDir -no-start-insert file<CR>

" ,uaでマッピングの一覧
nnoremap ,ua :<C-u>Unite mapping<CR>

" Ctrl-pでカレントディレクトリからファイルの一覧などを表示
nnoremap <C-p> :<C-u>Unite buffer file file_mru file_rec/git file_rec/async:.<CR>

" Ctrl-@で選択したディレクトリをVimFilerで開く
nnoremap <C-@> :<C-u>Unite
      \ -default-action=vimfiler
      \ directory directory_mru directory_rec/async:. ghq
      \ <CR>

" Ctrl-^で選択したディレクトリからファイルを列挙する
nnoremap <C-^> :<C-u>Unite
      \ -default-action=rec/async
      \ directory directory_mru directory_rec/async:. ghq
      \ <CR>

" Ctrl-_もしくはCtrl--でgrepする
nnoremap <C-_> :<C-u>Unite -winheight=30 grep:.<CR>

" }}}

" unite.vim sources {{{

NeoBundleLazy 'gh:Shougo/unite-outline.git', {
      \ 'on_source' : 'unite.vim'
      \ }
NeoBundleLazy 'gh:Shougo/unite-ssh.git', {
      \ 'on_source' : 'unite.vim'
      \ }
NeoBundleLazy 'gh:tsukkee/unite-tag.git', {
      \ 'on_source' : 'unite.vim'
      \ }
NeoBundleLazy 'gh:sorah/unite-ghq.git', {
      \ 'on_source' : 'unite.vim'
      \ }

" }}}

" neocomplete.vim {{{

" Luaが使用できてVimが特定のバージョン以降なら有効にする
NeoBundle 'gh:Shougo/neocomplete.vim.git', {
      \ 'disabled' : !has('lua'),
      \ 'vim_version' : '7.3.885',
      \ }

" neocompleteがインストールされている場合
if neobundle#is_installed('neocomplete.vim')
  " README.md - Setting examplesよりキーマップの変更
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

  " 改行した際に補完を閉じる
  inoremap <expr><CR>  neocomplete#smart_close_popup() . "\<CR>"

  " 補完を閉じ、文字を消す
  inoremap <expr><C-h> neocomplete#smart_close_popup() . "\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup() . "\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  " ペーストモードとキーバインドが被るのでコメントアウト
  "inoremap <expr><C-e>  neocomplete#cancel_popup()
endif

" neocompleteを有効にする
let g:neocomplete#enable_at_startup=1

" 入力に大文字を含む場合
let g:neocomplete#enable_smart_case=1

" unite.vimのバッファの場合は補完しない
let g:neocomplete#lock_buffer_name_pattern='\*unite\*'

" }}}

" neocomplcache.vim {{{

" Luaが使用できない場合に有効にする
NeoBundle 'gh:Shougo/neocomplcache.vim.git', {
      \ 'disabled' : has('lua'),
      \ }

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

" neocomplcacheを有効にする
let g:neocomplcache_enable_at_startup=1

" 入力に大文字を含む場合、大/小文字を無視しない
let g:neocomplcache_enable_smart_case=1

" キャメルケースの補完を有効にする
let g:neocomplcache_enable_camel_case_completion=1

" アンダースコアの補完を有効にする
let g:neocomplcache_enable_underbar_completion=1

" unite.vimのバッファの場合は補完しない
let g:neocomplcache_lock_buffer_name_pattern='\*unite\*'

" }}}

" neossh.vim {{{

NeoBundleLazy 'gh:Shougo/neossh.vim.git', {
      \ 'pre_cmd' : 'VimFiler',
      \ }

" }}}

" neoyank.vim {{{

NeoBundleLazy 'gh:Shougo/neoyank.vim.git', {
      \ 'on_source' : 'unite.vim',
      \ }

" ,uyでヤンク履歴の一覧
nnoremap ,uy :<C-u>Unite history/yank<CR>

" }}}

" neomru.vim {{{

NeoBundleLazy 'gh:Shougo/neomru.vim.git', {
      \ 'on_source' : 'unite.vim',
      \ }

" Ctrl-F2と,umで最近開いたファイル一覧
nnoremap <C-F2> :<C-u>Unite file_mru<CR>
nnoremap ,um :<C-u>Unite file_mru<CR>

" }}}

" vimfiler {{{

NeoBundleLazy 'gh:Shougo/vimfiler.git', {
      \ 'depends' : [
      \   'gh:Shougo/unite.vim.git',
      \   'gh:Shougo/neossh.vim.git',
      \ ],
      \ 'pre_cmd' : [
      \   'VimFiler',
      \ ],
      \ 'on_map' : '<Plug>',
      \ 'on_path' : '.*',
      \ }

" netrwを無効化する
let g:loaded_netrwPlugin = 1

" デフォルトのファイラにする
let g:vimfiler_as_default_explorer=1

" セーフモードをオフにする
let g:vimfiler_safe_mode_by_default=0

" 最大記憶ディレクトリ履歴を100にする
let g:vimfiler_max_directories_history=100

" F4と,vfで表示
nnoremap <F4> :<C-u>VimFilerBufferDir<CR>
nnoremap ,vf :<C-u>VimFilerBufferDir<CR>

" Shift-F4と,vFとTでエクスプローラ風の表示
nnoremap <S-F4> :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>
nnoremap ,vF :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>
nnoremap T :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -toggle -no-quit<CR>

" }}}

" vimshell {{{

NeoBundleLazy 'gh:Shougo/vimshell.vim.git', {
      \ 'pre_cmd' : [
      \   'VimFiler',
      \   'VimShell',
      \ ],
      \ }

" 大文字が入力された場合のみ大文字小文字を無視しない
let g:vimshell_smart_case=1

" プロンプトの上部にカレントディレクトリを表示する
let g:vimshell_user_prompt='fnamemodify(getcwd(), ":~")'

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

" vinarise {{{

NeoBundleLazy 'gh:Shougo/vinarise.git', {
      \ 'pre_cmd' : [
      \   'Vinarise',
      \ ],
      \ }

" }}}

" vim-ref {{{

NeoBundleLazy 'gh:thinca/vim-ref.git', {
      \ 'pre_cmd' : [
      \   'Ref',
      \ ],
      \ 'on_source' : 'unite.vim',
      \ }

" ,rmでmanをuniteで検索
nnoremap ,rm :<C-u>Unite ref/man<CR>

" }}}

" vim-qfreplace {{{

NeoBundleLazy 'gh:thinca/vim-qfreplace.git', {
      \ 'pre_cmd' : [
      \   'VimFiler',
      \ ],
      \ 'on_cmd' : 'Qfreplace',
      \ }

" }}}

" vim-quickrun {{{

NeoBundle 'gh:thinca/vim-quickrun.git'

" }}}

" gist-vim {{{

NeoBundleLazy 'gh:mattn/gist-vim.git', {
      \ 'depends' : 'gh:mattn/webapi-vim.git',
      \ 'on_cmd': 'Gist',
      \ }

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

" open-browser.vim {{{

NeoBundleLazy 'gh:tyru/open-browser.vim.git', {
      \ 'on_func' : 'OpenBrowser',
      \ 'on_map' : '<Plug>(openbrowser-smart-search)',
      \ 'pre_cmd': 'OpenBrowser',
      \ }

" settings from http://vim-jp.org/vim-users-jp/2011/08/26/Hack-225.html

" disable netrw's gx mapping.
let g:netrw_nogx = 1

nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

" }}}

" emmet-vim {{{

NeoBundleLazy 'gh:mattn/emmet-vim.git', {
      \ 'on_ft' : ['html', 'xml'],
      \ }

" 各種設定など
let g:user_emmet_settings = {
      \  'charset' : 'utf-8',
      \  'lang' : 'ja',
      \  'locale' : 'ja-JP',
      \  'html' : {
      \    'indentation' : ' ',
      \    'snippets' : {
      \      'html:5' : "<!DOCTYPE html>\n"
      \               . "<html>\n"
      \               . "<head>\n"
      \               . "  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">\n"
      \               . "  <meta charset=\"utf-8\">\n"
      \               . "  <title></title>\n"
      \               . "</head>\n"
      \               . "<body>\n"
      \               . "  ${child}|\n"
      \               . "</body>\n"
      \               . "</html>",
      \    }
      \  }
      \}

" }}}

" jscomplete-vim {{{

NeoBundleLazy 'bb:teramako/jscomplete-vim.git', {
      \ 'on_ft' : 'javascript',
      \ }

let g:jscomplete_use = ['dom', 'moz', 'es6th']

autocmd vimrc FileType javascript setlocal omnifunc=jscomplete#CompleteJS

" }}}

" tern_for_vim {{{

NeoBundleLazy 'gh:marijnh/tern_for_vim.git', {
      \ 'disabled' : !has('python'),
      \ 'autoload' : {
      \   'filetypes' : 'javascript',
      \ },
      \ 'build' : 'npm install',
      \ }

" }}}

" vim-textobj-multiblock {{{

NeoBundle 'gh:osyo-manga/vim-textobj-multiblock.git', {
      \ 'depends' : 'gh:kana/vim-textobj-user.git',
      \ }

" map from http://d.hatena.ne.jp/osyo-manga/20130329/1364569153
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
vmap ab <Plug>(textobj-multiblock-a)
vmap ib <Plug>(textobj-multiblock-i)

" }}}

" vim-operator-surround {{{

NeoBundle 'gh:rhysd/vim-operator-surround.git', {
      \ 'depends' : [
      \   'gh:kana/vim-operator-user.git',
      \   'gh:osyo-manga/vim-textobj-multiblock.git',
      \ ],
      \ }

" map from https://github.com/rhysd/vim-operator-surround
map <silent>sa <Plug>(operator-surround-append)
map <silent>sd <Plug>(operator-surround-delete)
map <silent>sr <Plug>(operator-surround-replace)

nmap <silent>sbd <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
nmap <silent>sbr <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)

" }}}

" vim-indent-guides {{{

NeoBundle 'gh:nathanaelkane/vim-indent-guides.git'

" インデントガイドの太さを1にする
let g:indent_guides_guide_size = 1

" 4レベル目のインデントからガイドを表示する
let g:indent_guides_start_level = 4

" 起動時に有効にする
let g:indent_guides_enable_on_vim_startup = 1

" 除外するファイルタイプ
let g:indent_guides_exclude_filetypes = [
      \ 'help',
      \ 'unite',
      \ 'vimfiler',
      \ 'vimshell',
      \ ]

" }}}

" eregex.vim {{{

NeoBundle 'gh:othree/eregex.vim.git'

" キーマップの変更などを行なわない
let g:eregex_default_enable = 0

" }}}

" {{{

NeoBundle 'gh:junegunn/vim-easy-align.git'

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}

" vim-over {{{

NeoBundleLazy 'gh:osyo-manga/vim-over.git', {
      \ 'pre_cmd' : 'OverCommandLine',
      \ }

" ,reでOverCommandLineを起動する
nnoremap <silent>,re :<C-u>OverCommandLine<CR>

" }}}

" lightline.vim {{{

NeoBundle 'gh:itchyny/lightline.vim.git'

" }}}

" syntax {{{

" vim-go-extra {{{

NeoBundleLazy 'gh:vim-jp/vim-go-extra.git', {
      \ 'build' : {
      \   'windows' : 'go get -u github.com/nsf/gocode',
      \   'cygwin' : 'go get -u github.com/nsf/gocode',
      \   'mac' : 'go get -u github.com/nsf/gocode',
      \   'unix' : 'go get -u github.com/nsf/gocode',
      \ },
      \ 'on_ft' : ['go'],
      \ }

" *.goはGo
autocmd vimrc BufNewFile,BufRead *.go setlocal filetype=go

" Go編集時にerrをハイライトする
" http://yuroyoro.hatenablog.com/entry/2014/08/12/144157
autocmd vimrc FileType go :highlight goErr cterm=bold ctermfg=214
autocmd vimrc FileType go :match goErr /\<err\>/

" Go編集時はタブにする
autocmd vimrc FileType go setlocal noexpandtab list tabstop=2 shiftwidth=2

" }}}

" JSON.vim {{{

NeoBundleLazy 'gh:vim-scripts/JSON.vim.git', {
      \ 'on_ft' : ['html', 'javascript'],
      \ }

" *.jsonはjson
autocmd vimrc BufNewFile,BufRead *.json setlocal filetype=json

" }}}

" vim-javascript {{{

NeoBundleLazy 'gh:pangloss/vim-javascript', {
      \ 'on_ft' : ['html', 'javascript'],
      \ }

" }}}

" html5.vim {{{

NeoBundleLazy 'gh:othree/html5.vim.git', {
      \ 'on_ft' : ['html', 'php'],
      \ }

" *.ejsと*.vueはHTML
autocmd vimrc BufNewFile,BufRead *.ejs,*.vue setlocal filetype=html

" }}}

" vim-coffee-script {{{

NeoBundleLazy 'gh:kchmck/vim-coffee-script.git', {
      \ 'on_ft' : ['coffee', 'markdown'],
      \ }

" *.coffeeはcoffee
autocmd vimrc BufNewFile,BufRead *.coffee setlocal filetype=coffee

" }}}

" vim-markdown {{{

NeoBundleLazy 'gh:tpope/vim-markdown.git', {
      \ 'on_ft' : 'markdown',
      \ }

" *.md,*.markdown,*.mkd,*.mdown,*.mkdn,*.markはmarkdown
autocmd vimrc BufNewFile,BufRead *.md,*.markdown,*.mkd,*.mdown,*.mkdn,*.mark setlocal filetype=markdown

" }}}

" vim-css3-syntax {{{

NeoBundleLazy 'gh:hail2u/vim-css3-syntax.git', {
      \ 'on_ft' : ['html', 'css'],
      \ }

" }}}

" vim-less {{{

NeoBundleLazy 'gh:groenewege/vim-less.git', {
      \ 'on_ft' : ['less'],
      \ }

" }}}

" vim-stylus {{{
NeoBundleLazy 'gh:wavded/vim-stylus.git', {
      \ 'on_ft' : ['stylus'],
      \ }

" }}}

" vim-pug {{{

NeoBundleLazy 'gh:digitaltoad/vim-pug.git', {
      \ 'on_ft' : ['jade', 'pug'],
      \ }

" *.jade,*.pugはpug
autocmd vimrc BufNewFile,BufRead *.jade,*.pug setlocal filetype=pug

" }}}

" typescript-vim {{{

NeoBundleLazy 'gh:leafgarland/typescript-vim.git', {
      \ 'on_ft' : ['typescript'],
      \ }

" *.tsはtypescript
autocmd vimrc BufNewFile,BufRead *.ts setlocal filetype=typescript

" }}}

" delphi.vim {{{

NeoBundleLazy 'gh:vim-scripts/delphi.vim.git', {
      \ 'on_ft' : ['delphi'],
      \ }

" *.dprと*.lprと*.pasと*.ppはDelphi
autocmd vimrc BufNewFile,BufRead *.dpr,*.lpr,*.pas,*.pp setlocal filetype=delphi

" }}}

" }}}

call neobundle#end()

filetype plugin indent on

" インストールされているかチェックする
" インストールされていない場合はインストールをする
NeoBundleCheck

" 標準添付されているmatchit.vimを読み込む
source $VIMRUNTIME/macros/matchit.vim

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

if (v:version == 704 && has('patch338')) || v:version >= 705
  " インデント付きで折り返す
  set breakindent
endif

" }}}

" ファイルタイプとか {{{

" *.binと*.exeと*.dllはxxd
autocmd vimrc BufNewFile,BufRead *.bin,*.exe,*.dll setlocal filetype=xxd

" *.xulはXML
autocmd vimrc BufNewFile,BufRead *.xul setlocal filetype=xml

" CSS編集時のみタブにする
autocmd vimrc FileType css setlocal noexpandtab list tabstop=8 shiftwidth=8

" SCSS編集時のみタブにする
autocmd vimrc FileType scss setlocal noexpandtab list tabstop=8 shiftwidth=8

" Makefile編集時のみタブにする
autocmd vimrc FileType make setlocal noexpandtab list tabstop=8 shiftwidth=8

" Python編集時のみインデントのスペース数を4にする
autocmd vimrc FileType python setlocal tabstop=4 shiftwidth=4

" }}}

" バッファとか {{{

set fileencoding=utf-8  " デフォルトの文字コード
set fileformat=unix     " デフォルトの改行コード

set nobomb  " BOMを付加しない
set hidden  " バッファを閉じないで非表示にする

if has('kaoriya') && has('guess_encode')
  " 文字コードの自動判別
  set fileencodings=guess
else
  " 開いたファイルに合っているものを順番に試す
  set fileencodings=ucs-bom,utf-8,cp932,euc-jp,utf-16,utf-16le,iso-2022-jp
endif

" 候補が1つだけの場合もポップアップメニューを表示する
set completeopt+=menuone

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

" 挿入モードを開始したときにペーストモードのキーバインドを設定する
autocmd vimrc InsertEnter * set pastetoggle=<C-e>

" 挿入モードから抜けるときにペーストモードを抜け、キーバインドも解除する
autocmd vimrc InsertLeave * set nopaste pastetoggle=

" }}}

" 表示とか {{{

syntax enable  " シンタックスハイライト

set number        " 行番号を表示する
set nowrap        " 折り返ししない
set showcmd       " コマンドを最下部に表示する
set shortmess+=I  " 起動時のメッセージを表示しない

set ttyfast     " 高速ターミナル接続を行なう
"set lazyredraw  " キーボードから実行されないコマンドの実行で再描画しない

" 一部の全角文字を全角の幅で扱う
set ambiwidth=double

" 折りたたみをインデントでする
set foldmethod=indent

" ステータスラインを常に表示する
set laststatus=2

" ステータスラインの表示を変更
set statusline=%n\:%y%F\ \|%{(&fenc!=''?&fenc:&enc).'\|'.(&ff=='dos'?'crlf':&ff=='mac'?'cr':'lf').'\|'}%m%r%=<%l:%v>

" 全角スペースに下線を引く
highlight FullWidthSpace cterm=underline ctermfg=Blue
autocmd vimrc WinEnter,WinLeave,BufRead,BufNew * match FullWidthSpace /　/

" コメント中の特定の単語を強調表示する
autocmd vimrc WinEnter,WinLeave,BufRead,BufNew,Syntax * call matchadd('Todo', '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\|NOTE\|INFO\|IDEA\)')

" ウィンドウを移動したらバッファ番号とフルパスを表示する
autocmd vimrc WinEnter * execute "normal! 2\<C-g>"

" Markdown内での強調表示
" http://mattn.kaoriya.net/software/vim/20140523124903.htm
let g:markdown_fenced_languages = [
      \ 'coffee',
      \ 'css',
      \ 'erb=eruby',
      \ 'html',
      \ 'javascript',
      \ 'js=javascript',
      \ 'json',
      \ 'ruby',
      \ 'sass',
      \ 'scss',
      \ 'xml',
      \ ]

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

" very magicをonにする
" http://deris.hatenablog.jp/entry/2013/05/15/024932
nnoremap / /\v

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

" (, )でバッファの移動
nnoremap ( :<C-u>bprevious<CR>
nnoremap ) :<C-u>bnext<CR>

" バッファ番号とフルパスを表示する
nnoremap <C-g> 2<C-g>

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

" バックアップファイルの保存先を変更
set backupdir=~/.backupdir,.,~/tmp,~/

" スワップファイルの保存先を変更
set directory=~/.swapdir,.,~/tmp,/var/tmp,/tmp

" アンドゥファイルの保存先を指定する
set undodir=~/.undodir,.,~/tmp,~/

if s:pt
  " ptコマンドを使用する場合の設定
  set grepprg=pt\ --nocolor\ --nogroup\ --smart-case
elseif s:w32 || s:w64
  " grepコマンドでvimgrepを使用する
  set grepprg=internal
else
  " 外部grepを使用する場合の設定
  set grepprg=grep\ -niEH
endif

" }}}

set secure

" vim:ft=vim:fdm=marker:fen:
