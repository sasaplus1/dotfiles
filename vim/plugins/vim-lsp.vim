scriptencoding utf-8

" use coc.nvim
finish

if has('nvim')
  finish
endif

function! s:on_lsp_buffer_enabled() abort
  nmap <buffer><silent> K <Plug>(lsp-hover)
endfunction
augroup lsp_install
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

function! s:hook_add() abort
" hook_add {{{
  " ポップアップの横幅を可変にする
  let g:lsp_float_max_width = 0

  " カーソル一のハイライトを有効化する
  let g:lsp_document_highlight_enabled = 1

  " ALEを使うのでdiagnosticsを無効化する
  let g:lsp_diagnostics_enabled = 0

  " カーソル位置のA>の表示を無効化する
  let g:lsp_document_code_action_signs_enabled = 0
" }}}
endfunction

function! s:hook_source() abort
" hook_source {{{
  if !dein#is_sourced('vim-lsp-settings')
    call dein#source('vim-lsp-settings')
  endif
" }}}
endfunction

call dein#add('prabirshrestha/vim-lsp', {
      \ 'hooks_file' : expand('<script>:p'),
      \ 'lazy' : 1,
      \ })

" vim:ft=vim:fdm=marker:fen:
