scriptencoding utf-8

if !exists('*dein#add')
  finish
endif

" 明示的に指定する
let g:ale_linters_explicit = 1

" aleで入力補完をしない
let g:ale_completion_enabled = 0

" aleでLSPを使わない
" tsserverが使えなくなってしまうのでコメントアウトする
" let g:ale_disable_lsp = 1

" LSPのヒントや提案を有効にする
let g:ale_lsp_suggestions = 1

" メッセージ書式を変更する
let g:ale_echo_msg_format = '[%linter%] %code: %%s'

" プレビューでメッセージを表示する
let g:ale_hover_to_preview = 1

" 保存した時にlintする
let g:ale_lint_on_save = 1

" 編集してもlintしない
let g:ale_lint_on_text_changed = 'never'

" 挿入モードから離れたらlintする
let g:ale_lint_on_insert_leave = 1

" 無視するファイルの設定
let g:ale_pattern_options = {
      \ '\.min\.js$' : { 'ale_enabled' : 0 },
      \ }

" 特定のファイルタイプに対して他のファイルタイプで使用するlinterを使えるようにする
let g:ale_linter_aliases = {
      \ 'javascript' : ['javascript', 'markdown'],
      \ 'javascript.jsx' : ['javascript', 'markdown'],
      \ 'javascriptreact' : ['javascript', 'markdown'],
      \ 'typescript' : ['typescript', 'markdown'],
      \ 'typescriptreact' : ['typescript', 'markdown'],
      \ }

" linterの設定
let g:ale_linters = {
      \ 'css' : ['stylelint'],
      \ 'javascript' : ['tsserver', 'eslint'],
      \ 'javascript.jsx' : ['tsserver', 'eslint'],
      \ 'javascriptreact' : ['tsserver', 'eslint'],
      \ 'json' : [],
      \ 'markdown' : ['textlint'],
      \ 'rust' : ['rust-analyzer', 'rls', 'cargo'],
      \ 'scss' : ['stylelint'],
      \ 'typescript' : ['tsserver', 'eslint', 'tslint'],
      \ 'typescriptreact' : ['tsserver', 'eslint', 'tslint'],
      \ }

" fixerの設定
" NOTE: aleでprettierを実行すると別窓のカーソル位置が変わってしまう
" 以下はvim-prettierのissueだがaleでも同様の問題が発生する
" https://github.com/prettier/vim-prettier/issues/192
" https://github.com/prettier/vim-prettier/issues/248
" 仕方がないのでcoc-prettierを使っている
" coc-prettierを設定した後にale.vimに戻したらale.vimでも発生しなくなった、何故？
let g:ale_fixers = {
      \ 'css' : ['prettier'],
      \ 'javascript' : ['prettier'],
      \ 'javascript.jsx' : ['prettier'],
      \ 'javascriptreact' : ['prettier'],
      \ 'json' : ['prettier'],
      \ 'markdown' : ['textlint'],
      \ 'rust' : ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],
      \ 'scss' : ['prettier'],
      \ 'typescript' : ['prettier'],
      \ 'typescriptreact' : ['prettier'],
      \ }

" 保存時fixする
autocmd vimrc BufNewFile,BufRead * let b:ale_fix_on_save = 1

function! s:ale_buffer_setup() abort
  " エラーのある行に移動する
  nnoremap <buffer><silent> [g :<C-u>ALEPreviousWrap<CR>
  nnoremap <buffer><silent> ]g :<C-u>ALENextWrap<CR>

  " 現在のバッファで有効・無効を切り替える
  nnoremap <buffer> ,ad :<C-u>ALEDisableBuffer<CR>
  nnoremap <buffer> ,ae :<C-u>ALEEnableBuffer<CR>

  " ALEの有効・無効を切り替える
  nnoremap <buffer> ,aD :<C-u>ALEDisable<CR>
  nnoremap <buffer> ,aE :<C-u>ALEEnable<CR>
endfunction
" バッファ固有のマップを設定する
autocmd vimrc BufNewFile,BufRead * call s:ale_buffer_setup()

" ファイルのカレントディレクトリから実行する
" monorepo毎に.eslintignoreがある場合などに有効
" autocmd vimrc BufNewFile,BufRead * let b:ale_command_wrapper = printf("cd '%s' && %s", expand("%:p:h"), '%*')

" JSONならprettierのパーサにjson-stringifyを使用する
autocmd vimrc FileType json let b:ale_javascript_prettier_options = '--parser json-stringify'

" eslintでの検査はキャッシュを使い、エラーが多いときは中断する
autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact,vue
      \ let b:ale_javascript_eslint_options = '--cache --max-warnings 20'

function! s:fix_with_eslint_plugin_prettier(dir) abort
  if empty(finddir('node_modules/eslint-plugin-prettier', a:dir . ';'))
    return
  endif

  let b:ale_fixers = extend(get(b:, 'ale_fixers', {}), {
        \ 'javascript' : ['eslint'],
        \ 'javascriptreact' : ['eslint'],
        \ 'javascript.jsx' : ['eslint'],
        \ 'typescript' : ['eslint'],
        \ 'typescriptreact' : ['eslint'],
        \ })
endfunction
" eslint-plugin-prettierがインストールされていたらそちらをfixerとして使う
autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact
      \ call s:fix_with_eslint_plugin_prettier(expand('%:p:h'))

function! s:add_textlint(dir) abort
  if empty(finddir('node_modules/textlint', a:dir . ';'))
    return
  endif

  let b:ale_linters = ['textlint']
endfunction
" textlintがインストールされていたらlinterに追加する
autocmd vimrc BufNewFile,BufRead * call s:add_textlint(expand('%:p'))

call dein#add('dense-analysis/ale', {
      \ 'lazy' : 1,
      \ 'on_ft' : [
      \   'css',
      \   'javascript',
      \   'javascript.jsx',
      \   'javascriptreact',
      \   'json',
      \   'markdown',
      \   'scss',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
