" pangloss/vim-javascript {{{
function! s:hook_source_vim_javascript() abort
  " JSDocのハイライトを有効化する
  let g:javascript_plugin_jsdoc = 1
endfunction

call dein#add('pangloss/vim-javascript', {
      \ 'hook_source' : function('s:hook_source_vim_javascript'),
      \ 'lazy' : 1,
      \ 'if' : !has('nvim'),
      \ 'on_ft' : [
      \   'javascript',
      \   'javascriptreact',
      \ ],
      \ })
" }}}


