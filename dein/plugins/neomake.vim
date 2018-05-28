" Functions
function! s:rebuffer(data) abort
  if &l:fileformat ==# 'dos'
    let a:data = substitute(data, "\r\n", "\n", 'g')
  endif

  let winView = winsaveview()

  silent 0,$ delete _
  silent $ put = a:data
  silent 1 delete _

  call winrestview(winView)
  redraw
endfunction

function! s:reopen() abort
  let format = &l:formatoptions
  let conceal = &l:conceallevel
  let winView = winsaveview()

  silent edit!

  call winrestview(winView)
  execute 'silent cd '. getcwd()

  let &l:formatoptions = format
  let &l:conceallevel = conceal

  if !exists('g:syntax_on')
    syntax on
  endif
endfunction

function! ProcessOutputBuffer(context) abort
  call s:rebuffer(a:context.output)
  return []
endfunction

function! ProcessOutputJson(context) abort
  let data = a:context.json[0]
  if has_key(data, 'output')
    call s:rebuffer(data.output)
  endif

  return []
endfunction

function! ProcessOutputFile() abort
  let jobinfo = g:neomake_hook_context.jobinfo
  if jobinfo.finished !=# 1
    return
  endif

  if jobinfo.maker.exe ==# 'php-cs-fixer'
    call s:reopen()
  endif
endfunction

let g:neomake_verbose = 0
let g:neomake_place_signs = 0
let g:neomake_highlight_lines = 1
let g:neomake_highlight_columns = 0
let g:neomake_echo_current_error = 1

" JavaScript
let g:neomake_javascript_enabled_makers = ['fix']
let g:neomake_javascript_fix_maker = {
  \ 'exe': 'eslint',
  \ 'args': [
  \   '--format=json', '--fix-dry-run', '--config', $CODING_STYLE_PATH . '/javascript/eslint-fix.js',
  \   '--cache', '--cache-location', $CACHE . '/eslint', '%:p'
  \ ],
  \ 'process_json': function('ProcessOutputJson'),
  \ }

" Rust
let g:neomake_rust_enabled_makers = ['fix']
let g:neomake_rust_fix_maker = {
  \ 'exe': 'rustfmt',
  \ 'args': ['-q', '--emit', 'stdout', '--config-path', $CODING_STYLE_PATH . '/rust/rustfmt.toml', '%:p'],
  \ 'append_file': 0,
  \ 'tempfile_enabled': 0,
  \ 'process_output': function('ProcessOutputBuffer'),
  \ }

" PHP
let g:neomake_php_enabled_makers = ['fix']
let g:neomake_php_fix_maker = {
  \ 'exe': 'php-cs-fixer',
  \ 'args': [
  \   'fix', '-q', printf('--config=%s/php/phpcs-fix.php', $CODING_STYLE_PATH),
  \   '--using-cache=yes', '--cache-file', $CACHE . '/phpcs', '%:p'
  \ ],
  \ }

AutocmdFT php
  \ Autocmd User NeomakeJobFinished call ProcessOutputFile()

" Golang
let g:neomake_go_enabled_makers = ['fix']
let g:neomake_go_fix_maker = {
  \ 'exe': 'gofmt',
  \ 'args': ['%:p'],
  \ 'append_file': 0,
  \ 'tempfile_enabled': 0,
  \ 'process_output': function('ProcessOutputBuffer'),
  \ }