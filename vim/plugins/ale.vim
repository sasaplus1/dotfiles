scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
  " 明示的に指定する
  let g:ale_linters_explicit = 1

  " aleでLSPを使う
  " LSPを使わないとtsserverが使えなくなってしまう
  let g:ale_disable_lsp = 0

  " aleで入力補完をしないがcoc.nvimがなければ入力補完をする
  let g:ale_completion_enabled = dein#tap('coc.nvim') ? 0 : 1

  " 入力補完を遅延させない
  let g:ale_completion_delay = 0

  " 自動的にimportを追加する
  let g:ale_completion_autoimport = 1

  " ホバーを有効にする
  let g:ale_hover_cursor = 1

  " バルーンで表示する？
  " 対応しているとデフォルトで有効になる
  " let g:ale_set_balloons = 1

  " エコーの遅延させない
  let g:ale_echo_delay = 0

  " カーソル位置の詳細を表示する
  " let g:ale_cursor_detail = 1

  " LSPのヒントや提案を有効にする
  let g:ale_lsp_suggestions = 1

  " メッセージ書式を変更する
  let g:ale_echo_msg_format = '[%linter%] %code: %%s'

  " プレビューでメッセージを表示する
  let g:ale_hover_to_preview = 1

  if has('nvim') || has('popupwin')
    " フローティングウィンドウでメッセージを表示する
    let g:ale_floating_preview = 1
    " let g:ale_hover_to_floating_preview = 1
    " let g:ale_detail_to_floating_preview = 1
  endif

  " coc.nvimに似せる
  let g:ale_floating_window_border = [' ', '', ' ', ' ', ' ', ' ', ' ', '']

  " 保存した時にlintする
  let g:ale_lint_on_save = 1

  " 保存した時にfixする
  let g:ale_fix_on_save = 1

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
        \ 'javascriptreact' : ['javascript', 'markdown'],
        \ 'typescript' : ['typescript', 'markdown'],
        \ 'typescriptreact' : ['typescript', 'markdown'],
        \ }

  " linterの設定
  let g:ale_linters = {
        \ 'css' : ['stylelint'],
        \ 'javascript' : ['tsserver', 'eslint'],
        \ 'javascriptreact' : ['tsserver', 'eslint'],
        \ 'json' : [],
        \ 'markdown' : ['textlint'],
        \ 'rust' : ['rust-analyzer', 'rls', 'cargo'],
        \ 'scss' : ['stylelint'],
        \ 'typescript' : ['tsserver', 'eslint'],
        \ 'typescriptreact' : ['tsserver', 'eslint'],
        \ }

  " fixerの設定
  " NOTE: aleでprettierを実行すると別窓のカーソル位置が変わってしまう
  " 以下はvim-prettierのissueだがaleでも同様の問題が発生する
  " https://github.com/prettier/vim-prettier/issues/192
  " https://github.com/prettier/vim-prettier/issues/248
  " 仕方がないのでcoc-prettierを使っている
  " coc-prettierを設定した後にale.vimに戻したらale.vimでも発生しなくなった、何故？
  let g:ale_fixers = {
        \ 'css' : ['stylelint', 'prettier'],
        \ 'javascript' : ['prettier'],
        \ 'javascriptreact' : ['prettier'],
        \ 'json' : ['prettier'],
        \ 'markdown' : ['textlint'],
        \ 'rust' : ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],
        \ 'scss' : ['stylelint', 'prettier'],
        \ 'typescript' : ['prettier'],
        \ 'typescriptreact' : ['prettier'],
        \ }

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

    if !dein#tap('coc.nvim')
      " LSP系機能
      nnoremap <silent> <C-]> :<C-u>ALEGoToDefinition<CR>
      nnoremap <silent> ,ld :<C-u>ALEGoToDefinition<CR>
      nnoremap <silent> ,lt :<C-u>ALEGoToTypeDefinition<CR>
      nnoremap <silent> ,li :<C-u>ALEGoToImplementation<CR>
      nnoremap <silent> ,lr :<C-u>ALEFindReferences<CR>
      nnoremap <silent> ,lR :<C-u>ALERename<CR>
    endif

    if !empty(finddir('node_modules/textlint', a:dir . ';'))
      " textlintがインストールされていたらlinterに追加する
      let linters = get(b:, 'ale_linters', {})

      if !has_key(linters, &filetype)
        let linters[&filetype] = []
      endif
      if index(linters[&filetype], 'textlint') == -1
        call add(linters[&filetype], 'textlint')
      endif

      let b:ale_linters = linters
    endif

  endfunction
  " バッファ固有のマップを設定する
  autocmd vimrc BufNewFile,BufRead * call s:ale_buffer_setup()

  autocmd vimrc FileType css,html,javascript,javascriptreact,json,rust,scss,typescript,typescriptreact
        \ if !dein#tap('coc.nvim') | nnoremap <buffer><silent> K :<C-u>ALEHover<CR> | endif

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
          \ 'typescript' : ['eslint'],
          \ 'typescriptreact' : ['eslint'],
          \ })
  endfunction
  " eslint-plugin-prettierがインストールされていたらそちらをfixerとして使う
  autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact
        \ call s:fix_with_eslint_plugin_prettier(expand('%:p:h'))

  " function! s:overwrite_eslint_function() abort
  "   if exists('s:patched_eslint_functions') && s:patched_eslint_functions
  "     return
  "   endif

  "   " The functions in this file are based on ale#handlers#eslint#FindConfig and ale#handlers#eslint#GetCwd,
  "   " which are under the MIT license.
  "   " Copyright (c) 2016-2023, Dense Analysis
  "   " All rights reserved.
  "   " https://github.com/dense-analysis/ale/blob/6c10a519f1460179cf8f8e329d8eb3186247be2b/LICENSE

  "   if exists('*ale#handlers#eslint#FindConfig')
  "     let s:sep = has('win32') ? '\' : '/'

  "     function! ale#handlers#eslint#FindConfig(buffer) abort
  "       for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
  "         for l:basename in [
  "               \ 'eslint.config.js',
  "               \ 'eslint.config.cjs',
  "               \ 'eslint.config.mjs',
  "               \ '.eslintrc.js',
  "               \ '.eslintrc.cjs',
  "               \ '.eslintrc.yaml',
  "               \ '.eslintrc.yml',
  "               \ '.eslintrc.json',
  "               \ '.eslintrc',
  "               \ ]
  "           let l:config = ale#path#Simplify(join([l:path, l:basename], s:sep))

  "           if filereadable(l:config)
  "             return l:config
  "           endif
  "         endfor
  "       endfor

  "       return ale#path#FindNearestFile(a:buffer, 'package.json')
  "     endfunction

  "     let s:patched_upwards = 1
  "   endif

  "   if exists('*ale#handlers#eslint#GetCwd')
  "     " see: https://github.com/dense-analysis/ale/issues/4487#issuecomment-1772044826
  "     " see: https://github.com/dense-analysis/ale/pull/4637
  "     function! ale#handlers#eslint#GetCwd(buffer) abort
  "       " Obtain the path to the ESLint configuration
  "       let l:config_path = ale#handlers#eslint#FindConfig(a:buffer)

  "       " Extract the directory from the config path
  "       let l:config_dir = fnamemodify(l:config_path, ':h')

  "       " Return the directory as the cwd
  "       return l:config_dir
  "     endfunction

  "     let s:patched_getcwd = 1
  "   endif

  "   let s:patched_eslint_functions =
  "         \ (exists('s:patched_upwards') && s:patched_upwards) &&
  "         \ (exists('s:patched_getcwd') && s:patched_getcwd)

  "   if s:patched_eslint_functions
  "     " 遅延読み込みをしている場合は設定を再読み込みさせる必要がある
  "     " :help ale-lint-settings-on-startup
  "     execute 'ALEDisable | ALEEnable'
  "   endif
  " endfunction
  " " flat configに対応する
  " autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact
  "       \ call s:overwrite_eslint_function()

  function! s:use_deno() abort
    if exists('b:called_use_deno') && b:called_use_deno
      return
    endif

    let dir = expand('%:p:h') . ';'
    let files = ['deno.json', 'deno.jsonc', 'deno.lock']

    let results = []

    " map(files, { v -> findfile(v, dir) })
    " だと思ったような結果にならないのでfor文で書く
    for file in files
      " それぞれのファイルを上方向に検索する
      call add(results, findfile(file, dir))
    endfor

    if empty(filter(results, '!empty(v:val)'))
      return
    endif

    " 他のlinterも使っている可能性があるので追加する
    let linters = get(b:, 'ale_linters', {
          \ 'typescript' : [],
          \ 'typescriptreact' : [],
          \ })
    call add(linters.typescript, 'deno')
    call add(linters.typescriptreact, 'deno')
    let b:ale_linters = linters

    " fixerはおそらくdenoだけだと思うのでdenoにする
    let b:ale_fixers = extend(get(b:, 'ale_fixers', {}), {
          \ 'typescript' : ['deno'],
          \ 'typescriptreact' : ['deno'],
          \ })
    let b:ale_fixers.typescript = ['deno']
    let b:ale_fixers.typescriptreact = ['deno']

    let b:called_use_deno = 1
  endfunction
  " denoのプロジェクトではdenoを使う
  autocmd vimrc FileType typescript,typescriptreact call s:use_deno()
" }}}
endfunction

function! s:hook_source() abort
" hook_source {{{
  if g:ale_completion_enabled
    set omnifunc=ale#completion#OmniFunc
  endif
" }}}
endfunction

call dein#add('dense-analysis/ale', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ 'on_cmd' : ['<Plug>(ale_'],
      \ 'on_ft' : [
      \   'css',
      \   'javascript',
      \   'javascriptreact',
      \   'json',
      \   'markdown',
      \   'scss',
      \   'typescript',
      \   'typescriptreact',
      \ ],
      \ })

" vim:ft=vim:fdm=marker:fen:
