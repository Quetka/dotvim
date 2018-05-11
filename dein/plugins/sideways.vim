nnoremap <silent> <C-h> :<C-u>call sideways#MoveLeft()<CR>
nnoremap <silent> <C-l> :<C-u>call sideways#MoveRight()<CR>
nnoremap <silent> <S-h> :<C-u>call sideways#JumpLeft()<CR>
nnoremap <silent> <S-l> :<C-u>call sideways#JumpRight()<CR>

let g:loaded_sideways = 1
let g:sideways_search_timeout = 0
let g:sideways_skip_strings_and_comments = 1

let g:sideways_definitions = [
  \   {
  \     'start': '(\_s*', 'end': ')',
  \     'delimiter': ',\_s*',
  \     'brackets': ['([{''"', ')]}''"'],
  \   },
  \   {
  \     'start': '\[\_s*', 'end': '\]',
  \     'delimiter': ',\_s*',
  \     'brackets': ['([{''"', ')]}''"'],
  \   },
  \   {
  \     'start': '{\_s*', 'end': '}',
  \     'delimiter': ',\_s*',
  \     'brackets': ['([{''"', ')]}''"'],
  \   },
  \ ]

AutocmdFT javascript let b:sideways_definitions = [
  \   {
  \     'start': '<\k\+\_s\+',
  \     'end': '\s*/\?>',
  \     'delimited_by_whitespace': 1,
  \     'brackets': ['"''{', '"''}'],
  \   },
  \ ]

AutocmdFT rust let b:sideways_definitions = [
  \   {
  \     'start': '\<[A-Z]\k\+<',
  \     'end': '>',
  \     'delimiter': ',\s*',
  \     'brackets': ['<([', '>)]'],
  \     'single_line': 1,
  \   },
  \   {
  \     'start': '::<',
  \     'end': '>',
  \     'delimiter': ',\s*',
  \     'brackets': ['<([', '>)]'],
  \     'single_line': 1,
  \   },
  \   {
  \     'start': ')\_s*->\_s*',
  \     'end': '\_s*{',
  \     'delimiter': 'NO_DELIMITER_SIDEWAYS_CARES_ABOUT',
  \     'brackets': ['<([', '>)]'],
  \   },
  \ ]

AutocmdFT php let b:sideways_definitions = [
  \   {
  \     'start': '<%=\=\s*\k\{1,}',
  \     'end': '\s*%>',
  \     'delimiter': ',\s*',
  \     'brackets': ['([''"', ')]''"'],
  \   },
  \ ]

AutocmdFT go let b:sideways_definitions = [
  \   {
  \     'start': '{\_s*',
  \     'end': '\_s*}',
  \     'delimiter': ',\s*',
  \     'brackets': ['([''"', ')]''"'],
  \   },
  \ ]
