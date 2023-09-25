scriptencoding utf-8

" *.binと*.exeと*.dllはxxd
autocmd vimrc BufNewFile,BufRead *.{bin,exe,dll} setfiletype xxd

" Podfileと*.podspecはruby
autocmd vimrc BufNewFile,BufRead Podfile,*.podspec setfiletype ruby

" *.cjsと*.jsと*.jsxと*.mjsと*.pacはJavaScript
autocmd vimrc BufNewFile,BufRead *.{cjs,js,jsx,mjs,pac} setfiletype javascript

" *.ctxと*.mtsと*.tsと*.tsxはTypeScript
autocmd vimrc BufNewFile,BufRead *.{cts,mts,ts,tsx} setfiletype typescript

if has('file_in_path')
  " gfで開く際に拡張子を補完する
  autocmd vimrc BufNewFile,BufRead *.{cjs,js,jsx,mjs,pac,ts,tsx}
        \ setlocal suffixesadd+=.tsx,.ts,.mjs,.cjs,.jsx,.js,.json,.pac
endif

" *.ftlはHTML
autocmd vimrc BufNewFile,BufRead *.ftl setfiletype html

" *.xulはXML
autocmd vimrc BufNewFile,BufRead *.xul setfiletype xml

" *.*.njkは1つ目の拡張子で判定する
" https://vi.stackexchange.com/a/29271
autocmd vimrc BufNewFile,BufRead *.*.njk execute 'doautocmd filetypedetect BufRead' fnameescape(expand('<afile>:r'))

" HTML編集時にシンタックスハイライトを400桁までに制限する
autocmd vimrc FileType html setlocal synmaxcol=400

" Makefile編集時のみタブにする
autocmd vimrc FileType make setlocal noexpandtab list tabstop=8 shiftwidth=8

" Python編集時のみインデントのスペース数を4にする
autocmd vimrc FileType python setlocal tabstop=4 shiftwidth=4

" Go言語 {{{

" Go編集時はタブにする
autocmd vimrc FileType go setlocal noexpandtab list tabstop=2 shiftwidth=2

" Go編集時にerrをハイライトする
" http://yuroyoro.hatenablog.com/entry/2014/08/12/144157
highlight goHighlight cterm=bold ctermfg=214
autocmd vimrc FileType go call matchadd('goHighlight', '\<\%(_\|err\)\>')

" Go編集時に末尾のセミコロンをハイライトする
highlight goSemicolon cterm=bold ctermfg=White ctermbg=Red
autocmd vimrc FileType go call matchadd('goSemicolon', ';\ze\s*$')

" }}}

" QuickFix {{{

" QuickFixを開いた時に簡単にプレビューをしたりする
" https://thinca.hatenablog.com/entry/20130708/1373210009
autocmd vimrc FileType qf nnoremap <buffer> p <CR>zz<C-w>p
" CtrlP相当
autocmd vimrc FileType qf nnoremap <buffer> <C-n> j
autocmd vimrc FileType qf nnoremap <buffer> <C-p> k

" }}}

" netrw {{{

" netrwでeやlを押したらCRと同じ動きにする
autocmd vimrc FileType netrw nmap <buffer> e <CR>
autocmd vimrc FileType netrw nmap <buffer> l <CR>
" netrwでhを押したら-と同じ動きにする
autocmd vimrc FileType netrw nmap <buffer> h -
" netrwでqを押したら閉じる
autocmd vimrc FileType netrw nnoremap <buffer><nowait><silent> q :<C-u>bwipeout!<CR>
" netrwでtを押したらツリーを閉じる
autocmd vimrc FileType netrw nmap <buffer><silent> t <Plug>NetrwTreeSqueeze
" netrwで<Space>を押したらマークする
autocmd vimrc FileType netrw nmap <buffer><expr> <Space> getline('.') == getline('$') ? 'mf' : 'mfj'
" netrwでMを押したらマークを外す
autocmd vimrc FileType netrw nmap <buffer> M mF
" netrwでドットファイルの表示・非表示を切り替える
autocmd vimrc FileType netrw nmap <buffer> . gh
" netrwで新しいファイルを作る
autocmd vimrc FileType netrw nmap <buffer> N %
" netrwで新しいディレクトリを作る
autocmd vimrc FileType netrw nmap <buffer> K d
" netrwで$HOMEに移動する
autocmd vimrc FileType netrw nmap <buffer><silent> ~ :<C-u>Explore $HOME<CR>
" netrwで/に移動する
autocmd vimrc FileType netrw nmap <buffer><silent> \ :<C-u>Explore /<CR>

" }}}

" ペーストモード {{{

" 挿入モードを開始したときにペーストモードのキーバインドを設定する
autocmd vimrc InsertEnter * setlocal pastetoggle=<C-t>
" 挿入モードから抜けるときにペーストモードを抜け、キーバインドも解除する
autocmd vimrc InsertLeave * setlocal nopaste pastetoggle=

" }}}

" コメント中の特定の単語を強調表示する
autocmd vimrc WinEnter,WinLeave,BufRead,BufNew *
      \ call matchadd('Todo', '\<\%(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\|NOTE\|INFO\|IDEA\)\>')

" ウィンドウを移動したらバッファ番号とフルパスを表示する
autocmd vimrc WinEnter * execute 'normal! 2\<C-g>'

" 全角スペースに下線を引く
highlight FullWidthSpace cterm=underline ctermfg=Blue
autocmd vimrc WinEnter,WinLeave,BufRead,BufNew * match FullWidthSpace /　/

" Markdown {{{

" Markdown編集時のみインデントのスペース数を4にする
autocmd vimrc FileType markdown setlocal tabstop=4 shiftwidth=4
" いくつかの拡張子をMarkdownとして開く
autocmd vimrc BufNewFile,BufRead *.{md,markdown,mkd,mdown,mkdn,mark} setfiletype markdown

" Jekyllのための保存時刻自動入力設定
" https://jekyllrb.com/docs/frontmatter/
"function! s:set_autodate_for_jekyll()
"  " バッファローカルなautodate.vimの設定
"  " http://nanasi.jp/articles/vim/autodate_vim.html
"  let b:autodate_lines = 5
"  let b:autodate_keyword_pre = 'date: '
"  let b:autodate_keyword_post = '$'
"  let b:autodate_format = '%Y-%m-%d %H:%M:%S'
"endfunction
" Markdownファイルを開いたときにだけ実行する
"autocmd vimrc BufNewFile,BufRead *.{md,markdown,mkd,mdown,mkdn,mark} call s:set_autodate_for_jekyll()

" }}}

" JavaScriptの著名なモジュールの設定ファイルをJSONとして開く
autocmd vimrc BufNewFile,BufRead .{babel,eslint,stylelint,swc,textlint}rc setfiletype json

" make,vimgrep,vimgrepaddを実行したらcopenをする
" grep,grepaddはCtrlPQuickfixを使用する
autocmd vimrc QuickfixCmdPost make,vimgrep,vimgrepadd copen

" vimdiffなどdiffをするときはカラースキームを変更する
" https://stackoverflow.com/a/2019401
autocmd vimrc FilterWritePre * if &diff | colorscheme industry | endif

" Terminal {{{

if has('terminal') && has('patch-8.1.2219')
  " ターミナルを開いたら行番号を表示しない
  autocmd vimrc TerminalWinOpen * setlocal nonumber norelativenumber
endif

if has('nvim')
  " ターミナルを開いたら行番号を表示しない
  autocmd vimrc TermOpen * setlocal nonumber norelativenumber
  " ターミナルを開いたら挿入モードにする
  autocmd vimrc TermOpen * startinsert
  " ターミナルで正常終了したら閉じてバッファを削除する
  autocmd vimrc TermClose * if !v:event.status | execute 'bdelete! ' . expand('<abuf>') | endif
endif

" }}}

if filereadable($VIMRUNTIME . '/macros/matchit.vim')
  " 標準添付されているmatchit.vimを読み込む
  autocmd vimrc VimEnter ++nested source $VIMRUNTIME/macros/matchit.vim
endif

" vim:ft=vim:fdm=marker:fen:
