scriptencoding utf-8

" 設定例を読み込まない
let g:no_gvimrc_example = 1
let g:no_vimrc_example = 1

" 標準添付プラグインを読み込まない
let g:loaded_2html_plugin = 1
let g:loaded_dvorak_plugin = 1
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_logiPat = 1
let g:loaded_matchparen = 1
" let g:loaded_netrw = 1
" let g:loaded_netrwFileHandlers = 1
" let g:loaded_netrwPlugin = 1
" let g:loaded_netrwSettings = 1
let g:loaded_rrhelper = 1
let g:loaded_spellfile_plugin = 1
let g:loaded_gzip = 1
let g:loaded_tar = 1
let g:loaded_tarPlugin = 1
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
let g:loaded_zip = 1
let g:loaded_zipPlugin = 1
let g:did_install_default_menus = 1
let g:skip_loading_mswin = 1
let g:did_install_syntax_menu = 1
let g:no_gvimrc_example = 1
let g:no_vimrc_example = 1

" KaoriYaのプラグインを読み込まない
let g:plugin_autodate_disable = 1
" let g:plugin_cmdex_disable = 1
let g:plugin_dicwin_disable = 1
let g:plugin_hz_ja_disable = 1
let g:plugin_scrnmode_disable = 1
" let g:plugin_verifyenc_disable = 1

" netrwの設定
" ls -lのように表示する
let g:netrw_liststyle = 1
" バナーを表示しない
let g:netrw_banner = 0
" ファイルサイズを読みやすくする
let g:netrw_sizestyle = 'H'
" タイムスタンプの表示を変更する
let g:netrw_timefmt = '%Y/%m/%d %H:%M'
" キャッシュを使用しない
let g:netrw_fastbrowse = 0

" デフォルトシェルをBashにする
" 詳しくは :help sh.vim を参照
let g:is_bash = 1

" Markdown内での強調表示
" http://mattn.kaoriya.net/software/vim/20140523124903.htm
let g:markdown_fenced_languages = [
      \ 'css',
      \ 'diff',
      \ 'erb=eruby',
      \ 'html',
      \ 'javascript',
      \ 'js=javascript',
      \ 'json',
      \ 'ruby',
      \ 'sass',
      \ 'scss',
      \ 'sh',
      \ 'typescript',
      \ 'ts=typescript',
      \ 'vim',
      \ 'xml',
      \ ]

" vim:ft=vim:fdm=marker:fen:
