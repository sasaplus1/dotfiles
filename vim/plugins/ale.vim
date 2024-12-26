scriptencoding utf-8

function! s:hook_add() abort
" hook_add {{{
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
        \ 'css' : ['stylelint', 'prettier'],
        \ 'javascript' : ['prettier'],
        \ 'javascript.jsx' : ['prettier'],
        \ 'javascriptreact' : ['prettier'],
        \ 'json' : ['prettier'],
        \ 'markdown' : ['textlint'],
        \ 'rust' : ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'],
        \ 'scss' : ['stylelint', 'prettier'],
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

  function! s:overwrite_eslint_function() abort
    if exists('s:patched_eslint_functions') && s:patched_eslint_functions
      return
    endif

    " The functions in this file are based on ale#handlers#eslint#FindConfig and ale#handlers#eslint#GetCwd,
    " which are under the MIT license.
    " Copyright (c) 2016-2023, Dense Analysis
    " All rights reserved.
    " https://github.com/dense-analysis/ale/blob/6c10a519f1460179cf8f8e329d8eb3186247be2b/LICENSE

    if exists('*ale#handlers#eslint#FindConfig')
      let s:sep = has('win32') ? '\' : '/'

      function! ale#handlers#eslint#FindConfig(buffer) abort
        for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
          for l:basename in [
                \ 'eslint.config.js',
                \ 'eslint.config.cjs',
                \ 'eslint.config.mjs',
                \ '.eslintrc.js',
                \ '.eslintrc.cjs',
                \ '.eslintrc.yaml',
                \ '.eslintrc.yml',
                \ '.eslintrc.json',
                \ '.eslintrc',
                \ ]
            let l:config = ale#path#Simplify(join([l:path, l:basename], s:sep))

            if filereadable(l:config)
              return l:config
            endif
          endfor
        endfor

        return ale#path#FindNearestFile(a:buffer, 'package.json')
      endfunction

      let s:patched_upwards = 1
    endif

    if exists('*ale#handlers#eslint#GetCwd')
      " see: https://github.com/dense-analysis/ale/issues/4487#issuecomment-1772044826
      " see: https://github.com/dense-analysis/ale/pull/4637
      function! ale#handlers#eslint#GetCwd(buffer) abort
        " Obtain the path to the ESLint configuration
        let l:config_path = ale#handlers#eslint#FindConfig(a:buffer)

        " Extract the directory from the config path
        let l:config_dir = fnamemodify(l:config_path, ':h')

        " Return the directory as the cwd
        return l:config_dir
      endfunction

      let s:patched_getcwd = 1
    endif

    let s:patched_eslint_functions =
          \ (exists('s:patched_upwards') && s:patched_upwards) &&
          \ (exists('s:patched_getcwd') && s:patched_getcwd)

    if s:patched_eslint_functions
      " 遅延読み込みをしている場合は設定を再読み込みさせる必要がある
      " :help ale-lint-settings-on-startup
      execute 'ALEDisable | ALEEnable'
    endif
  endfunction
  " flat configに対応する
  autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact
        \ call s:overwrite_eslint_function()
" }}}
endfunction

call dein#add('dense-analysis/ale', {
      \ 'hooks_file' : expand('<script>:p'),
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
