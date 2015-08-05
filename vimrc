" .vimrc / 2015 Aug
" Author: Alex Masterov <alex.masterow@gmail.com>
" Source: https://github.com/AlexMasterov/vimfiles

" My vimfiles
"---------------------------------------------------------------------------
    let $VIMFILES = $VIM.'/vimfiles'
    let $VIMCACHE = $VIMFILES.'/cache'

" Environment
"---------------------------------------------------------------------------
    " The prefix keys
    nmap ; [prefix]
    noremap [prefix] <Nop>

    let &suffixes = ''
    " Ignore pattern
    let g:ignore_pattern =
    \  'hq,git,svn'
    \. ',png,jpg,jpeg,gif,ico,bmp'
    \. ',zip,rar,tar,tar.bz,tar.bz2'
    \. ',o,a,so,obj.pyc,bin,exe,lib,dll'
    \. ',lock,bak,tmp,dist,doc,docx,md'
    \. ',otf,ttf,svg,svgz'

    let s:is_windows = has('win32') || has('win64')

    if &compatible
        set nocompatible  " be improved
    endif
    if s:is_windows
        set shellslash
    endif
    set noexrc            " avoid reading local (g)vimrc, exrc
    set modelines=0       " prevents security exploits

    " Initialize autogroup in MyVimrc
    augroup MyVimrc| exe 'autocmd!' |augroup END

    " Echo startup time on start
    if has('vim_starting') && has('reltime')
        " Shell: vim --startuptime filename -q; vim filename
        " vim --cmd 'profile start profile.txt' --cmd 'profile file $HOME/.vimrc' +q && vim profile.txt
        let s:startuptime = reltime()
        autocmd MyVimrc VimEnter * let s:startuptime = reltime(s:startuptime) | redraw
                        \| echomsg ' startuptime:'. reltimestr(s:startuptime)
    endif

" Functions
"---------------------------------------------------------------------------
    function! MakeDir(dir, ...)
        let dir = expand(a:dir, 1)
        if !isdirectory(dir)
            \ && (a:0 || input(printf('"%s" does not exist. Create? [y/n]', dir)) =~? '^y\%[es]$')
            silent! call mkdir(iconv(dir, &encoding, &termencoding), 'p')
        endif
    endfunction

    function! s:isBackspace()
        let col = col('.') - 1
        return !col || getline('.')[col - 1] =~ '\s'
    endfunction

" Commands
"---------------------------------------------------------------------------
    " Vimrc augroup sugar
    command! -nargs=* Autocmd   autocmd MyVimrc <args>
    command! -nargs=* AutocmdFT autocmd MyVimrc FileType <args>
    command! -bar -nargs=* Indent
        \ exe 'setl tabstop='.<q-args> 'softtabstop='.<q-args> 'shiftwidth='.<q-args>
    command! -nargs=* FontSize
        \ let &guifont = substitute(&guifont, '\d\+', '\=<args>', 'g')
    command! -nargs=* Mkdir call MakeDir(<f-args>)
    " Rename current file name
    command! -nargs=1 -complete=file Rename f <args>| w |call delete(expand('#'))
    " Strip trailing whitespace at the end of non-blank lines
    command! -bar FixWhitespace if !&bin| silent! :%s/\s\+$//ge | :let @/="" |endif

" Events
"---------------------------------------------------------------------------
    " Reload vimrc
    Autocmd BufWritePost,FileWritePost $MYVIMRC source $MYVIMRC | redraw
    " Don't auto insert a comment when using O/o for a newline (see also :help fo-table)
    Autocmd BufEnter,WinEnter,InsertEnter * setl formatoptions-=ro
    " Toggle settings between modes
    Autocmd InsertEnter * setl list colorcolumn=120
    Autocmd InsertLeave * setl nolist colorcolumn=
    " Resize splits then the window is resized
    Autocmd VimResized * wincmd =
    " Create directories if not exist
    Autocmd BufWritePre * call MakeDir('<afile>:p:h', v:cmdbang)
    " Convert tabs to soft tabs if expandtab is set
    " Autocmd BufWritePre * if &expandtab| exe '%s/\t/'. repeat(' ', &tabstop) .'/ge' |endif

" Encoding
"---------------------------------------------------------------------------
    set encoding=utf-8
    scriptencoding utf-8

    if s:is_windows && has('multi_byte')
        setglobal fileencodings=utf-8,cp1251
        set termencoding=cp850  " cmd.exe uses cp850
    else
        set termencoding=       " same as 'encoding'
    endif

    " Default fileformat
    set fileformat=unix
    set fileformats=unix,dos,mac

    " Open in UTF-8
    command! -bar -bang -nargs=? -complete=file Utf8 edit<bang> ++enc=utf-8 <args>
    " Open in CP1251
    command! -bar -bang -nargs=? -complete=file Cp1251 edit<bang> ++enc=cp1251 <args>

" Misc
"---------------------------------------------------------------------------
    if has('vim_starting')
        set viminfo+=n$VIMFILES/viminfo
        " Cache
        call MakeDir($VIMCACHE, 1)
        set noswapfile
        " Undo
        call MakeDir($VIMFILES.'/undo', 1)
        set undofile
        set undolevels=500 undoreload=1000
        set undodir=$VIMFILES/undo
        " View
        set viewdir=$VIMFILES/views
        set viewoptions=cursor,slash,unix
    endif

    " Russian keyboard
    set iskeyword=@,48-57,_,192-255
    set keymap=russian-jcukenwin
    if has('multi_byte')
        set iminsert=0 imsearch=0
    endif

    " Regexp engine (0=auto, 1=old, 2=NFA)
    if exists('&regexpengine')
        set regexpengine=1
    endif

" Plugins
"---------------------------------------------------------------------------
    " Avoid loading same default plugins
    let g:loaded_gzip = 1
    let g:loaded_zipPlugin = 1
    let g:loaded_tarPlugin = 1
    let g:loaded_logipat = 1
    let g:loaded_rrhelper = 1
    let g:loaded_matchparen = 1
    let g:loaded_netrwPlugin = 1
    let g:loaded_2html_plugin = 1
    let g:loaded_vimballPlugin = 1
    let g:loaded_getscriptPlugin = 1
    let g:loaded_spellfile_plugin = 1
    let g:did_install_default_menus = 1

    " Install NeoBundle
    if has('vim_starting')
        let s:neobundlePath = $VIMFILES.'/bundle/neobundle.vim'
        if !isdirectory(s:neobundlePath)
            call MakeDir($VIMFILES.'/bundle', 1)
            if executable('git')
                let s:neobundleUri  = 'https://github.com/Shougo/neobundle.vim'
                call system(printf('git clone --depth 1 %s %s', s:neobundleUri, s:neobundlePath))
            else
                echom "Can\'t download NeoBundle: Git not found."
            endif
        endif
        exe 'set runtimepath=$VIMFILES,$VIMRUNTIME,'. s:neobundlePath
    endif
    let g:neobundle#types#git#clone_depth = 1
    let g:neobundle#install_max_processes =
        \ exists('$NUMBER_OF_PROCESSORS') ? str2nr($NUMBER_OF_PROCESSORS) : 1

    function! CacheBundles()
        " Let NeoBundle manage NeoBundle
        NeoBundleFetch 'Shougo/neobundle.vim'
        " Local plugins for doing development
        exe 'NeoBundleLocal '.$VIMFILES.'/dev'

        NeoBundleLazy 'Shougo/vimproc.vim', {
        \ 'build': {
        \   'mac':     'make -f make_mac.mak',
        \   'unix':    'make -f make_unix.mak',
        \   'windows': 'tools\\update-dll-mingw'
        \}}

        " Utils
        NeoBundle 'kopischke/vim-stay'
        NeoBundle 'kshenoy/vim-signature'
        NeoBundleLazy 'tpope/vim-characterize'
        NeoBundleLazy 'mbbill/undotree'
        NeoBundleLazy 'Shougo/vimfiler.vim'
        NeoBundleLazy 'tpope/vim-projectionist'
        NeoBundleLazy 'lilydjwg/colorizer'
        NeoBundleLazy 'LeafCage/yankround.vim'
        NeoBundleLazy 'Shougo/unite.vim'
        NeoBundleLazy 'Shougo/neomru.vim'
        NeoBundleLazy 'Shougo/unite-outline'
        NeoBundleLazy 'osyo-manga/unite-vimpatches'
        NeoBundleLazy 'osyo-manga/unite-quickfix'
        NeoBundleLazy 'osyo-manga/unite-filetype'
        NeoBundleLazy 'thinca/vim-qfreplace'
        NeoBundleLazy 'mattn/httpstatus-vim'
        NeoBundleLazy 'tsukkee/unite-tag'
        NeoBundleLazy 'jaxbot/semantic-highlight.vim'
        " NeoBundleLazy 'osyo-manga/vim-brightest'
        NeoBundleLazy 'xolox/vim-misc'
        NeoBundleLazy 'xolox/vim-session', {
        \ 'depends': 'xolox/vim-misc'
        \}
        NeoBundleLazy 'arecarn/selection.vim'
        NeoBundleLazy 'arecarn/crunch.vim', {
        \ 'depends': 'arecarn/selection.vim'
        \}
        NeoBundleLazy 'thinca/vim-quickrun', {
        \ 'depends': 'Shougo/vimproc.vim'
        \}

        " Edit
        NeoBundleLazy 'tyru/caw.vim'
        NeoBundleLazy 'kana/vim-smartword'
        NeoBundleLazy 't9md/vim-smalls'
        NeoBundleLazy 'cohama/lexima.vim'
        NeoBundleLazy 'habamax/vim-skipit'
        NeoBundleLazy 'gcmt/wildfire.vim'
        NeoBundleLazy 'saihoooooooo/glowshi-ft.vim'
        NeoBundleLazy 'junegunn/vim-easy-align'
        NeoBundleLazy 'AndrewRadev/sideways.vim'
        NeoBundleLazy 'AndrewRadev/splitjoin.vim'
        NeoBundleLazy 'jakobwesthoff/argumentrewrap'
        NeoBundleLazy 'triglav/vim-visual-increment'
        NeoBundleLazy 'AndrewRadev/switch.vim'
        NeoBundleLazy 'kana/vim-smartchr'
        NeoBundleLazy 'Shougo/context_filetype.vim'
        NeoBundleLazy 'Shougo/neoinclude.vim'
        NeoBundleLazy 'Shougo/neco-syntax'
        NeoBundleLazy 'Shougo/neocomplete.vim', {
        \ 'depends': [
        \   'Shougo/context_filetype.vim', 'Shougo/neoinclude.vim', 'Shougo/neco-syntax'
        \ ],
        \ 'disabled': !has('lua'),
        \}
        NeoBundleLazy 'SirVer/ultisnips', {
        \ 'disabled': !has('python'),
        \}

        " Text objects
        NeoBundleLazy 'kana/vim-textobj-user'
        NeoBundleLazy 'machakann/vim-textobj-delimited', {
        \ 'depends': 'kana/vim-textobj-user'
        \}
        NeoBundleLazy 'whatyouhide/vim-textobj-xmlattr', {
        \ 'depends': 'kana/vim-textobj-user'
        \}
        " NeoBundleLazy 'justinj/vim-textobj-reactprop', {
        " \ 'depends': 'kana/vim-textobj-user'
        " \}

        " Haskell
        " NeoBundleLazy 'itchyny/vim-haskell-indent'
        NeoBundleLazy 'philopon/haskell-indent.vim'
        NeoBundleLazy 'enomsg/vim-haskellConcealPlus'
        NeoBundleLazy 'Twinside/vim-syntax-haskell-cabal'
        NeoBundleLazy 'eagletmt/ghcmod-vim', {
        \ 'disabled': !executable('ghc-mod'),
        \}
        NeoBundleLazy 'eagletmt/neco-ghc', {
        \ 'disabled': !executable('ghc-mod'),
        \}
        " PHP
        " NeoBundleLazy 'joonty/vdebug'
        " NeoBundleLazy 'swekaj/php-foldexpr.vim'
        NeoBundleLazy '2072/PHP-Indenting-for-VIm'
        NeoBundleLazy 'shawncplus/phpcomplete.vim'
        NeoBundleLazy 'tobyS/vmustache'
        NeoBundleLazy 'tobyS/pdv', {
        \ 'depends': 'tobyS/vmustache',
        \}
        " JavaScript
        NeoBundleLazy 'othree/yajs.vim'
        NeoBundleLazy 'othree/javascript-libraries-syntax.vim'
        NeoBundleLazy 'jiangmiao/simple-javascript-indenter'
        NeoBundleLazy 'hujo/jscomplete-html5API'
        NeoBundleLazy  'https://bitbucket.org/teramako/jscomplete-vim.git'
        NeoBundleLazy 'heavenshell/vim-jsdoc'
        " HTML
        NeoBundle 'alvan/vim-closetag'
        NeoBundle 'gregsexton/MatchTag'
        NeoBundleLazy 'othree/html5.vim'
        NeoBundleLazy 'mattn/emmet-vim'
        " Twig
        NeoBundleLazy 'qbbr/vim-twig'
        NeoBundleLazy 'tokutake/twig-indent'
        " CSS
        NeoBundleLazy 'JulesWang/css.vim'
        NeoBundleLazy 'hail2u/vim-css3-syntax'
        NeoBundleLazy '1995eaton/vim-better-css-completion'
        " NeoBundleLazy 'rstacruz/vim-hyperstyle'
        " LESS
        NeoBundleLazy 'groenewege/vim-less'
        " JSON
        NeoBundleLazy 'elzr/vim-json'
        " JSX
        NeoBundleLazy 'mxw/vim-jsx'
        " SQL
        NeoBundleLazy 'shmup/vim-sql-syntax'
        " Nginx
        NeoBundleLazy 'yaroot/vim-nginx'
        " CSV
        NeoBundleLazy 'chrisbra/csv.vim'
        " Docker
        NeoBundleLazy 'ekalinin/Dockerfile.vim'

        " NeoBundleCheck
        NeoBundleSaveCache
    endfunction

    call neobundle#begin($VIMFILES.'/bundle')
    if neobundle#load_cache()
        call CacheBundles()
    endif
    call neobundle#end()

    filetype plugin indent on
    if !exists('g:syntax_on')| syntax on |endif

" Bundle settings
"---------------------------------------------------------------------------
    if neobundle#tap('crunch.vim')
        call neobundle#config({
        \ 'mappings': [['n', '<Plug>'], ['x', '<Plug>(visual-crunch-operator)']],
        \ 'commands': 'Crunch'
        \})

        nmap ,x <Plug>(crunch-operator)
        nmap ,X <Plug>(crunch-operator-line)
        xmap ,x <Plug>(visual-crunch-operator)
        " ,z: toggle crunch append
        nnoremap <silent> ,z
            \ :<C-u>let g:crunch_result_type_append = !get(g:, 'crunch_result_type_append', 0)<CR>
            \:echo ' Crunch append: '. (g:crunch_result_type_append == 1 ? 'On' : 'Off')<CR>

        function! neobundle#hooks.on_source(bundle)
            let g:crunch_result_type_append = get(g:, 'crunch_result_type_append', 0)
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-quickrun')
        call neobundle#config({
        \ 'mappings': [['n', '<Plug>(quickrun)']],
        \ 'functions': ['quickrun#is_running', 'quickrun#sweep_sessions'],
        \ 'commands': 'QuickRun'
        \})

        nmap ,, <Plug>(quickrun)
        nnoremap <expr> <silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"

        AutocmdFT javascript,html,css,json
            \ nnoremap ,b :<C-u>QuickRun -formatter<CR>

        function! neobundle#hooks.on_source(bundle)
            let g:quickrun_config = get(g:, 'quickrun_config', {})
            let g:quickrun_config._ = {
            \ 'outputter':                 'null',
            \ 'runner':                    'vimproc',
            \ 'runner/vimproc/updatetime': 30
            \}

            " JavaScript
            let g:quickrun_config.javascript = {
            \ 'type': executable('esformatter') ? 'javascript/formatter' : ''
            \}
            let g:quickrun_config['javascript/formatter'] = {
            \ 'command':   'esformatter',
            \ 'exec':      '%c %s',
            \ 'outputter': 'rebuffer'
            \}

            " HTML
            let g:quickrun_config.html = {
            \ 'type': executable('html-beautify') ? 'html/formatter' : ''
            \}
            let s:html_config = ' --indent-size 2'
            let g:quickrun_config.html = {
            \ 'command':   'html-beautify',
            \ 'exec':      '%c -f %s'. s:html_config,
            \ 'outputter': 'rebuffer'
            \}
            " Twig
            let g:quickrun_config.twig = g:quickrun_config.html
            let g:quickrun_config.htmltwig = g:quickrun_config.html

            " CSS
            let g:quickrun_config.css = {
            \ 'type': executable('css-beautify') ? 'css/formatter' : ''
            \}
            let s:css_config = ' --indent-size 2'
            let g:quickrun_config['css/formatter'] = {
            \ 'command': 'css-beautify',
            \ 'exec':    '%c -f %s'. s:css_config,
            \ 'outputter': 'rebuffer'
            \}

            " JSON
            let g:quickrun_config.json = {
            \ 'type': executable('js-beautify') ? 'json/formatter' : ''
            \}
            let s:json_config = ' --indent-size 2'
            let g:quickrun_config['json/formatter'] = {
            \ 'command': 'js-beautify',
            \ 'exec':    '%c -f %s'. s:json_config,
            \ 'outputter': 'rebuffer'
            \}

            " Outputters
            let s:rebuffer = {'name': 'rebuffer', 'kind': 'outputter'}

            function! s:rebuffer.output(data, session) abort
                let self.result = a:data
            endfunction

            function! s:rebuffer.finish(session) abort
                if a:session.exit_code == 1 " if error
                    return
                endif

                let data = self.result
                let winView = winsaveview()

                normal! ggdG
                silent $ put = data
                silent 1 delete _

                call winrestview(winView)
                redraw
            endfunction

            call quickrun#module#register(s:rebuffer, 1)
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-characterize')
        call neobundle#config({'mappings': '<Plug>(characterize)'})

        nmap ,c <Plug>(characterize)

        call neobundle#untap()
    endif

    if neobundle#tap('selection.vim')
        call neobundle#config({'augroup': 'SELECTION_MODE'})

        function! neobundle#hooks.on_post_source(bundle)
            augroup SELECTION_MODE
                autocmd!
            augroup END
            augroup! SELECTION_MODE
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('undotree')
        call neobundle#config({'commands': 'UndotreeToggle'})

        nnoremap <silent> ,u :<C-u>call <SID>undotreeMyToggle()<CR>
        AutocmdFT diff,undotree setl nornu nonu colorcolumn=

        function! neobundle#hooks.on_source(bundle)
            let g:undotree_WindowLayout = 4
            let g:undotree_SplitWidth = 36
            let g:undotree_SetFocusWhenToggle = 1

            AutocmdFT diff Autocmd BufEnter,WinEnter <buffer>
                \  nnoremap <silent> <buffer> q :<C-u>UndotreeHide<CR>
                \| nnoremap <silent> <buffer> ` :<C-u>UndotreeHide<CR>
        endfunction

        function! s:undotreeMyToggle()
            if &filetype != 'php'
                let s:undotree_last_ft = &filetype
                AutocmdFT diff Autocmd BufEnter,WinEnter <buffer>
                    \ let &l:syntax = s:undotree_last_ft
            endif
            UndotreeToggle
        endfunction

        function! g:Undotree_CustomMap()
            nmap <buffer> o <Enter>
            nmap <buffer> u <Plug>UndotreeUndo
            nmap <buffer> r <Plug>UndotreeRedo
            nmap <buffer> h <Plug>UndotreeGoNextState
            nmap <buffer> l <Plug>UndotreeGoPreviousState
            nmap <buffer> d <Plug>UndotreeDiffToggle
            nmap <buffer> t <Plug>UndotreeTimestampToggle
            nmap <buffer> C <Plug>UndotreeClearHistory
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-session')
        call neobundle#config({
        \ 'functions':
        \   ['xolox#session#complete_names', 'xolox#session#complete_names_with_suggestions'],
        \ 'commands': [
        \   {'name': ['OpenSession', 'DeleteSession'],
        \       'complete': 'customlist,xolox#session#complete_names'},
        \   {'name': 'SaveSession',
        \       'complete': 'xolox#session#complete_names_with_suggestions'},
        \   'SaveSession', 'OpenSession', 'CloseSession', 'RestartVim'
        \]})

        nmap <F9> :<C-u>RestartVim!<CR>
        nmap ,sl  :<C-u>OpenSession!<Space>
        nmap ,ss  :<C-u>SaveSession!<CR>
        nmap ,sc  :<C-u>CloseSession!<CR>
        nmap ,sd  :<C-u>DeleteSession!<Space>
        nmap ,sa  :<C-u>call <SID>inputSessionName()<CR>
        nmap ,ss  :<C-u>SessionSaveWithTimeStamp<CR>

        command! -nargs=0 SessionSaveWithTimeStamp
            \ exe ':SaveSession '. strftime('%y%m%d_%H%M%S')

        function! s:inputSessionName()
            let session_name = input(" Session name: \n\r ")
            if session_name != ''
                exe ':SaveSession '. escape(session_name, '"')
            endif
        endfunction

        function! neobundle#hooks.on_source(bundle)
            let g:session_autosave = 0
            let g:session_autoload = 0
            let g:session_persist_colors = 0
            let g:session_directory = $VIMFILES.'/session'
            set sessionoptions-=blank,help,options
        endfunction

        call neobundle#untap()
    endif

    if neobundle#is_installed('vim-signature')
        let g:SignatureMarkTextHL = "'BookmarkLine'"
        let g:SignatureIncludeMarks = 'weratsdfqglcvbzxyi'
        let g:SignatureErrorIfNoAvailableMarks = 0
        let g:SignatureMap = {
        \ 'Leader':           '\|',
        \ 'ToggleMarkAtLine': '\',
        \ 'PurgeMarksAtLine': '<BS>',
        \ 'DeleteMark':       '<S-BS>',
        \ 'PurgeMarks':       '<Del>',
        \ 'PurgeMarkers':     '<S-Del>',
        \}

        " jump to any marker
        nnoremap <silent> + :<C-u>call signature#marker#Goto('next', 'any',  v:count)<CR>zz
        nnoremap <silent> _ :<C-u>call signature#marker#Goto('next', 'any',  v:count)<CR>zz
        " jump to spot alpha
        nnoremap <silent> = :<C-u>call signature#mark#Goto('next', 'spot', 'alpha')<CR>zz
        nnoremap <silent> - :<C-u>call signature#mark#Goto('prev', 'spot', 'alpha')<CR>zz
        " jump to line alpha
        nnoremap <silent> <Up> :<C-u>call signature#mark#Goto('next', 'line', 'alpha')<CR>zz
        nnoremap <silent> <Down> :<C-u>call signature#mark#Goto('prev', 'line', 'alpha')<CR>zz

        Autocmd BufRead * SignatureRefresh
        Autocmd VimEnter,Colorscheme *
            \ hi BookmarkLine guifg=#2B2B2B guibg=#F9EDDF gui=NONE
        AutocmdFT unite nmap <buffer> <BS> <Nop>
    endif

    if neobundle#tap('vimfiler.vim')
        call neobundle#config({'commands': ['VimFiler', 'VimFilerCurrentDir']})

        " [dD]: open vimfiler explrer
        nnoremap <silent> [prefix]d
            \ :<C-u>VimFiler -split -toggle -invisible -project -no-quit<CR>
        nnoremap <silent> [prefix]D
            \ :<C-u>VimFiler -split -toggle -invisible -project -force-quit<CR>

        " Vimfiler tuning
        AutocmdFT vimfiler
            \ setl nonu nornu nolist cursorline colorcolumn=
            \| Autocmd BufLeave,BufDelete,WinLeave <buffer> setl nocursorline
            \| Autocmd BufEnter,WinEnter <buffer> setl cursorline

        AutocmdFT vimfiler call s:VimfilerMappings()
        function! s:VimfilerMappings()
            " Normal mode
            nmap <buffer> <expr> q winnr('$') == 1
                \ ? "\<Plug>(vimfiler_hide)"
                \ : "\<Plug>(vimfiler_switch_to_other_window)"
            nmap <buffer> Q <Plug>(vimfiler_close)
            nmap <buffer> ` <Plug>(vimfiler_hide)
            nmap <buffer> l <Plug>(vimfiler_expand_tree)
            nmap <buffer> o <Plug>(vimfiler_expand_or_edit)
            nmap <buffer> O <Plug>(vimfiler_open_file_in_another_vimfiler)
            nmap <buffer> <nowait> n <Plug>(vimfiler_new_file)
            nmap <buffer> <nowait> N <Plug>(vimfiler_make_directory)
            nmap <buffer> <nowait> c <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_copy_file)
            nmap <buffer> <nowait> m <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_move_file)y
            nmap <buffer> <nowait> d <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_delete_file)y
            nmap <buffer> D <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_force_delete_file)
            nmap <buffer> e <Plug>(vimfiler_toggle_mark_current_line)
            nmap <buffer> E <Plug>(vimfiler_clear_mark_all_lines)
            nmap <buffer> R <Plug>(vimfiler_redraw_screen)
            nmap <buffer> <expr> <nowait> v vimfiler#do_switch_action('vsplit')
            nmap <buffer> <expr> <nowait> s vimfiler#do_switch_action('split')
            nmap <buffer> <expr> S <Plug>(vimfiler_split_edit_file)
            nmap <buffer> <expr> t vimfiler#do_action('tabopen')
            nmap <buffer> <expr> <Enter>
                \ vimfiler#smart_cursor_map("\<Plug>(vimfiler_expand_tree)", "\<Plug>(vimfiler_edit_file)")

            " <Space>[hjkl]: jump to a window
            for s in ['h', 'j', 'k', 'l']
                exe printf('nnoremap <silent> <buffer> <Space>%s :<C-u>wincmd %s<CR>', s, s)
            endfor | unlet s

            " Unbinds
            nmap <buffer> J <Nop>
            nmap <buffer> K <Nop>
            nmap <buffer> L <Nop>
        endfunction

        function! neobundle#hooks.on_source(bundle)
            let g:vimfiler_force_overwrite_statusline = 0
            let g:vimfiler_data_directory = $VIMCACHE.'/vimfiler'
            let g:unite_kind_file_use_trashbox = s:is_windows

            let g:vimfiler_ignore_pattern =
                \ '^\%(\..*\|.git\|bin\|node_modules\)$'

            " Icons
            let g:vimfiler_file_icon = ' '
            let g:vimfiler_tree_leaf_icon = ' '
            let g:vimfiler_tree_opened_icon = '▾'
            let g:vimfiler_tree_closed_icon = '▸'
            let g:vimfiler_marked_file_icon = '+'

            " Default profile
            let s:vimfiler_default = {
            \ 'safe': 0,
            \ 'parent': 0,
            \ 'explorer': 1,
            \ 'winwidth': 22
            \}

            " Custom profiles
            call vimfiler#custom#profile('default', 'context', s:vimfiler_default)
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-projectionist')
        call neobundle#config({'functions': 'ProjectionistDetect'})

        " [prefix]p: detect .projections.json
        nnoremap <silent> [prefix]p :<C-u>call ProjectionistDetect(resolve(expand('<afile>:p')))<CR>

        function! neobundle#hooks.on_source(bundle)
            nnoremap m1 :<C-u>Ejs<Space>
            nnoremap m2 :<C-u>Ecss<Space>
            nnoremap m3 :<C-u>Epackage<Space>
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-visual-increment')
        call neobundle#config({'mappings': ['<Plug>VisualIncrement', '<Plug>VisualDecrement']})

        xmap <C-a> <Plug>VisualIncrement
        xmap <C-x> <Plug>VisualDecrement

        function! neobundle#hooks.on_source(bundle)
            " CTRL+A and CTRL+X works also for letters
            set nrformats+=alpha
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-smartword')
        call neobundle#config({'mappings': '<Plug>'})

        nmap w  <Plug>(smartword-w)
        nmap e  <Plug>(smartword-e)
        nmap b  <Plug>(smartword-b)
        nmap ge <Plug>(smartword-ge)
        vmap w  <Plug>(smartword-w)
        vmap e  <Plug>(smartword-e)
        vmap b  <Plug>(smartword-b)
        vmap ge <Plug>(smartword-ge)

        call neobundle#untap()
    endif

    if neobundle#tap('vim-easy-align')
        call neobundle#config({'mappings': '<Plug>(EasyAlign)'})

        vmap <Enter> <Plug>(EasyAlign)

        function! neobundle#hooks.on_source(bundle)
            let g:easy_align_ignore_groups = ['Comment', 'String']
            let g:easy_align_delimiters = {
            \ '>': {'pattern': '>>\|=>\|>' },
            \ '/': {'pattern': '//\+\|/\*\|\*/', 'delimiter_align': 'l', 'ignore_groups': ['^\(.\(Comment\)\@!\)*$']},
            \ ']': {'pattern': '[[\]]', 'left_margin': 0, 'right_margin': 0, 'stick_to_left': 0},
            \ ')': {'pattern': '[()]', 'left_margin': 0, 'right_margin': 0, 'stick_to_left': 0},
            \ 'f': {'pattern': ' \(\S\+(\)\@=', 'left_margin': 0, 'right_margin': 0 },
            \ 'd': {'pattern': ' \(\S\+\s*[;=]\)\@=', 'left_margin': 0, 'right_margin': 0}
            \}
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-brightest')
        call neobundle#config({'filetypes': ['php', 'javascript']})

        function! neobundle#hooks.on_source(bundle)
            let g:brightest#enable_filetypes = {
            \ '_': 0,
            \ 'php': 1,
            \ 'javascript': 1
            \}
            let g:brightest#highlight = {'group': 'BrightestCursorLine'}
            let g:brightest#ignore_syntax_list = ['Comment']

            hi BrightestCursorLine guifg=#2B2B2B guibg=#FBF8EA gui=NONE
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('sideways.vim')
        call neobundle#config({'commands': 'Sideways'})

        nnoremap <silent> <C-h> :<C-u>SidewaysLeft<CR>
        nnoremap <silent> <C-l> :<C-u>SidewaysRight<CR>
        nnoremap <silent> <S-h> :<C-u>SidewaysJumpLeft<CR>
        nnoremap <silent> <S-l> :<C-u>SidewaysJumpRight<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('yankround.vim')
        call neobundle#config({
        \ 'unite_sources': 'yankround',
        \ 'mappings': '<Plug>'
        \})

        nmap p <Plug>(yankround-p)
        xmap p <Plug>(yankround-p)
        nmap P <Plug>(yankround-P)
        nmap <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "\<C-p>"
        nmap <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "\<C-n>"

        " [prefix]y: yankround
        nnoremap <silent> [prefix]y :<C-u>Unite yankround -buffer-name=yankround<CR>

        function! neobundle#hooks.on_source(bundle)
            let g:yankround_max_history = 10
            let g:yankround_use_region_hl = 1
            let g:yankround_region_hl_groupname = 'TODO'
            let g:yankround_dir = $VIMCACHE.'/yankround'
        endfunction

        call neobundle#untap()
    endif

    " https://medium.com/@evnbr/coding-in-color-3a6db2743a1e
    if neobundle#tap('semantic-highlight.vim')
        call neobundle#config({'commands': 'SemanticHighlightToggle'})

        AutocmdFT php,javascript,jsx
            \ nnoremap <silent> <buffer> ,v :<C-u>SemanticHighlightToggle<CR>

        function! neobundle#hooks.on_source(bundle)
            let g:semanticPersistCacheLocation = $VIMCACHE.'/semantic-hl'
            let g:semanticGUIColors = [
            \ '#CD7F32', '#999999', '#0050B1', '#A67F59'
            \]
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('wildfire.vim')
        call neobundle#config({'mappings': '<Plug>'})

        nmap vv    <Plug>(wildfire-fuel)
        xmap vv    <Plug>(wildfire-fuel)
        xmap <C-v> <Plug>(wildfire-water)

        function! neobundle#hooks.on_source(bundle)
            let g:wildfire_objects = {
            \ '*': split("iw iW i' i\" i) a) a] a}"),
            \ 'html,twig,htmltwig,xml': ["at"]
            \}
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('caw.vim')
        call neobundle#config({'mappings': ['q', ',q', ',a', ',w']})

        function! neobundle#hooks.on_source(bundle)
            let g:caw_no_default_keymappings = 1
            let g:caw_i_skip_blank_line = 1

            nmap <expr> q v:count >= 2
                \ ? printf('<Esc>V%dj<Plug>(caw:wrap:toggle)%dl', (v:count-1), col('.'))
                \ : '<Plug>(caw:wrap:toggle)'
            xmap <expr> q printf('<Plug>(caw:wrap:toggle)%dl', col('.'))
            nmap ,q <Plug>(caw:jump:comment-prev)
            nmap ,w <Plug>(caw:jump:comment-next)
            nmap ,a <Plug>(caw:a:toggle)
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('argumentrewrap')
        call neobundle#config({'functions': 'argumentrewrap#RewrapArguments'})

        map <silent> K :<C-u>call argumentrewrap#RewrapArguments()<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('splitjoin.vim')
        call neobundle#config({'commands': ['SplitjoinJoin', 'SplitjoinSplit']})

        nmap <silent> J :<C-u>SplitjoinJoin<CR><CR>
        nmap <silent> S :<C-u>SplitjoinSplit<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('vim-smalls')
        call neobundle#config({'mappings': '<Plug>'})

        nmap s <Plug>(smalls)
        nmap ,f <Plug>(smalls-excursion)

        function! neobundle#hooks.on_source(bundle)
            let g:smalls_highlight = {
            \ 'SmallsCandidate':  [['NONE', 'NONE', 'NONE'],['NONE', '#DDEECC', '#000000']],
            \ 'SmallsCurrent':    [['NONE', 'NONE', 'NONE'],['bold', '#9DBAD7', '#000000']],
            \ 'SmallsJumpTarget': [['NONE', 'NONE', 'NONE'],['NONE', '#FF7311', '#000000']],
            \ 'SmallsPos':        [['NONE', 'NONE', 'NONE'],['NONE', '#FF7311', '#000000']],
            \ 'SmallsCli':        [['NONE', 'NONE', 'NONE'],['bold', '#DDEECC', '#000000']]
            \}
            call smalls#keyboard#cli#extend_table({
            \ "\<S-Space>": 'do_excursion',
            \ "\<C-o>":     'do_excursion',
            \ "\<C-i>":     'do_excursion',
            \ "\<C-j>":     'do_excursion',
            \ "\<C-k>":     'do_excursion',
            \ "\<C-l>":     'do_cancel',
            \ "\<C-c>":     'do_cancel',
            \ "\q":         'do_cancel',
            \ "\`":         'do_cancel'
            \})
            call smalls#keyboard#excursion#extend_table({
            \ "\Q": 'do_cancel',
            \ "\o": 'do_set',
            \ "\`": 'do_set',
            \ "\p": 'do_jump'
            \})
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('glowshi-ft.vim')
        call neobundle#config({'mappings': '<Plug>'})

        map f <Plug>(glowshi-ft-f)
        map F <Plug>(glowshi-ft-F)

        function! neobundle#hooks.on_source(bundle)
            let g:glowshi_ft_fix_key = '[\<NL>\o]'
            let g:glowshi_ft_cancel_key = '\`'
            let g:glowshi_ft_selected_hl_guibg = '#9DBAD7'
            let g:glowshi_ft_candidates_hl_guibg = '#DDEECC'
            let g:glowshi_ft_no_default_key_mappings = 1
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-skipit')
        call neobundle#config({'mappings': [['i', '<C-n>']]})

        function! neobundle#hooks.on_source(bundle)
            imap  <C-n> <Plug>SkipIt
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('lexima.vim')
        call neobundle#config({'insert': 1})

        function! neobundle#hooks.on_source(bundle)
            let g:lexima_no_default_rules = 1
            let g:lexima_no_map_to_escape = 1
            let g:lexima_enable_newline_rules = 1
            let g:lexima_enable_endwise_rules = 0

            silent! call remove(g:lexima#default_rules, 11, -1)
            for rule in g:lexima#default_rules
                call lexima#add_rule(rule)
            endfor | unlet rule

            function! s:disable_lexima_inside_regexp(char)
                call lexima#add_rule({'char': a:char, 'at': '\(...........\)\?/\S.*\%#.*\S/', 'input': a:char})
            endfunction

            " Fix pair completion
            for pair in ['()', '[]', '{}']
                call lexima#add_rule({
                \ 'char': pair[0], 'at': '\(........\)\?\%#[^\s'. escape(pair[1], ']') .']', 'input': pair[0]
                \})
            endfor | unlet pair

            " Quotes
            for quote in ['"', "'"]
                call lexima#add_rule({'char': quote, 'at': '\(.......\)\?\%#\w', 'input': quote})
                call lexima#add_rule({'char': quote, 'at': '\(.......\)\?'. quote .'\%#', 'input': quote})
                call lexima#add_rule({'char': quote, 'at': '\(...........\)\?\%#'. quote, 'input': '<Right>'})
                call s:disable_lexima_inside_regexp(quote)
            endfor | unlet quote

            " { <CR> }
            call lexima#add_rule({'char': '<CR>', 'at': '{\%#}', 'input_after': '<CR>'})
            call lexima#add_rule({'char': '<CR>', 'at': '{\%#$', 'input_after': '<CR>}', 'filetype': []})

            " { <Space> }
            let s:lexima_pair_space_ft = ['javascript']
            call lexima#add_rule({
            \ 'char': '<Space>', 'at': '{\%#}', 'input': '<Space>', 'input_after': '<Space>',
            \ 'filetype': s:lexima_pair_space_ft
            \})

            " Attributes
            let s:lexima_attr_close_ft = ['html', 'twig', 'htmltwig', 'xml', 'javascript.jsx']
            call lexima#add_rule({
            \ 'char': '=', 'at': '\(........\)\?<.\+\%#', 'input': '=""<Left>',
            \ 'filetype': s:lexima_attr_close_ft
            \})
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('switch.vim')
        call neobundle#config({
        \ 'functions': 'switch#Switch',
        \ 'commands': "Switch"
        \})

        nnoremap <silent> <Tab> :<C-u>Switch<CR>
        xnoremap <silent> <Tab> :Switch<CR>
        nnoremap <silent> ` :<C-u>silent! call switch#Switch(g:switch_def_camelcase)<CR>
        nnoremap <silent> ! :<C-u>silent! call switch#Switch(g:switch_def_quotes)<CR>

        let g:switch_mapping = ''
        let g:switch_def_quotes = [{
        \ '''\(.\{-}\)''': '"\1"',
        \ '"\(.\{-}\)"':  '''\1''',
        \ '`\(.\{-}\)`':  '''\1'''
        \}]
        let g:switch_def_camelcase = [{
        \ '\<\(\l\)\(\l\+\(\u\l\+\)\+\)\>': '\=toupper(submatch(1)) . submatch(2)',
        \ '\<\(\u\l\+\)\(\u\l\+\)\+\>': "\\=tolower(substitute(submatch(0), '\\(\\l\\)\\(\\u\\)', '\\1_\\2', 'g'))",
        \ '\<\(\l\+\)\(_\l\+\)\+\>': '\U\0',
        \ '\<\(\u\+\)\(_\u\+\)\+\>': "\\=tolower(substitute(submatch(0), '_', '-', 'g'))",
        \ '\<\(\l\+\)\(-\l\+\)\+\>': "\\=substitute(submatch(0), '-\\(\\l\\)', '\\u\\1', 'g')"
        \}]

        " PHP
        AutocmdFT php
        \ let b:switch_custom_definitions = [
        \ ['development', 'production'],
        \ ['&&', '||'],
        \ ['and', 'or'],
        \ ['public', 'protected', 'private'],
        \ ['extends', 'implements'],
        \ ['use', 'namespace'],
        \ ['var_dump', 'print_r'],
        \ ['array', 'string'],
        \ ['include', 'require'],
        \ ['$_GET', '$_POST', '$_REQUEST'],
        \ {
        \   '\([^=]\)===\([^=]\)': '\1==\2',
        \   '\([^=]\)==\([^=]\)': '\1===\2'
        \ },
        \ {
        \   '\[[''"]\(\k\+\)[''"]\]': '->\1',
        \   '\->\(\k\+\)': '[''\1'']'
        \ }
        \]

        " HTML
        AutocmdFT html,twig,htmltwig
        \ let b:switch_custom_definitions = [
        \ ['h1', 'h2', 'h3'],
        \ ['png', 'jpg', 'gif'],
        \ ['id=', 'class=', 'style='],
        \ {
        \   '<div\(.\{-}\)>\(.\{-}\)</div>': '<span\1>\2</span>',
        \   '<span\(.\{-}\)>\(.\{-}\)</span>': '<div\1>\2</div>'
        \ },
        \ {
        \   '<ol\(.\{-}\)>\(.\{-}\)</ol>': '<ul\1>\2</ul>',
        \   '<ul\(.\{-}\)>\(.\{-}\)</ul>': '<ol\1>\2</ol>'
        \ }
        \]

        " CSS
        AutocmdFT css
        \ let b:switch_custom_definitions = [
        \ ['border-top', 'border-bottom'],
        \ ['border-left', 'border-right'],
        \ ['border-left-width', 'border-right-width'],
        \ ['border-top-width', 'border-bottom-width'],
        \ ['border-left-style', 'border-right-style'],
        \ ['border-top-style', 'border-bottom-style'],
        \ ['margin-left', 'margin-right'],
        \ ['margin-top', 'margin-bottom'],
        \ ['padding-left', 'padding-right'],
        \ ['padding-top', 'padding-bottom'],
        \ ['margin', 'padding'],
        \ ['height', 'width'],
        \ ['min-width', 'max-width'],
        \ ['min-height', 'max-height'],
        \ ['transition', 'animation'],
        \ ['absolute', 'relative', 'fixed'],
        \ ['overflow', 'overflow-x', 'overflow-y'],
        \ ['before', 'after'],
        \ ['none', 'block'],
        \ ['left', 'right'],
        \ ['top', 'bottom'],
        \ ['em', 'px', '%']
        \]

        call neobundle#untap()
    endif

    if neobundle#tap('vim-smartchr')
        call neobundle#config({'functions': 'smartchr#loop'})

        command! -nargs=* ImapBufExpr inoremap <buffer> <expr> <args>
        AutocmdFT haskell
            \  ImapBufExpr \ smartchr#loop('\ ', '\')
            \| ImapBufExpr - smartchr#loop('-', ' -> ', ' <- ')
        AutocmdFT php
            \  ImapBufExpr $ smartchr#loop('$', '$this->', '$$')
            \| ImapBufExpr > smartchr#loop('>', '=>')
        AutocmdFT javascript
            \| ImapBufExpr - smartchr#loop('-', '--', '_')
            \| ImapBufExpr $ smartchr#loop('$', 'this.', 'self.')
        AutocmdFT yaml
            \  ImapBufExpr > smartchr#loop('>', '%>')
            \| ImapBufExpr < smartchr#loop('<', '<%', '<%=')

        call neobundle#untap()
    endif

    if neobundle#tap('vim-textobj-delimited')
        call neobundle#config({'mappings': ['vid', 'viD', 'vad', 'vaD']})
        call neobundle#untap()
    endif

    if neobundle#tap('vim-textobj-xmlattr')
        call neobundle#config({'mappings': ['vix', 'vax']})
        call neobundle#untap()
    endif

    if neobundle#tap('vim-textobj-reactprop')
        call neobundle#config({'mappings': ['var', 'cir']})
        call neobundle#untap()
    endif

    if neobundle#tap('colorizer')
        let s:color_codes_ft = 'css,less,html,twig,htmltwig'
        call neobundle#config({
        \ 'filetypes': split(s:color_codes_ft, ','),
        \ 'commands': ['ColorToggle', 'ColorHighlight', 'ColorClear']
        \})

        function! neobundle#hooks.on_source(bundle)
            let g:colorizer_nomap = 1

            Autocmd BufNewFile,BufRead,BufEnter,BufWinEnter,WinEnter *
                \ exe index(split(s:color_codes_ft, ','), &filetype) == -1
                \ ? 'call <SID>clearColor()'
                \ : 'ColorHighlight'

            function! s:clearColor()
                augroup Colorizer
                    autocmd!
                augroup END
                augroup! Colorizer
            endfunction
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('context_filetype.vim')
        function! neobundle#hooks.on_source(bundle)
            let g:context_filetype#search_offset = 500

            function! s:addContext(rule, filetype)
                let s:context_ft_def = context_filetype#default_filetypes()
                let g:context_filetype#filetypes[a:filetype] = add(s:context_ft_def.html, a:rule)
            endfunction

            " CSS
            let s:context_ft_css = {
            \ 'start':    '<style>',
            \ 'end':      '</style>',
            \ 'filetype': 'css',
            \}
            call <SID>addContext(s:context_ft_css, 'html')

            " Coffee script
            let s:context_ft_coffee = {
            \ 'start':    '<script\%( [^>]*\)\? type="text/coffee"\%( [^>]*\)\?>',
            \ 'end':      '</script>',
            \ 'filetype': 'coffee',
            \}
            call <SID>addContext(s:context_ft_coffee, 'html')

            " JSX (React)
            let s:context_ft_jsx = {
            \ 'start':    '<script\%( [^>]*\)\? type="text/jsx"\%( [^>]*\)\?>',
            \ 'end':      '</script>',
            \ 'filetype': 'javascript.jsx',
            \}
            call <SID>addContext(s:context_ft_jsx, 'html')
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('neocomplete.vim')
        call neobundle#config({'insert': 1})

        " Ctrl-d: select the previous match OR delete till start of line
        inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-g>u<C-u>"
        " Ctrl-k: select the next match OR delete to end of line
        inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : col('.') == col('$') ? "\<C-k>" : "\<C-o>D"
        " <C-x><C-f>: file
        inoremap <silent> <expr> <C-x><C-f> neocomplete#start_manual_complete('file')

        " Tab: completion
        inoremap <silent> <Tab> <C-r>=<SID>neoComplete()<CR>
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-x>\<C-o>"

        function! s:neoComplete()
            if pumvisible()
                return "\<C-n>"
            endif

            if <SID>isBackspace() == 1
                return "\<Tab>"
            endif

            call feedkeys("\<C-x>\<C-i>")
            return neocomplete#start_manual_complete()
        endfunction

        function! neobundle#hooks.on_source(bundle)
            let g:neocomplete#enable_at_startup = 1
            let g:neocomplete#enable_smart_case = 1
            let g:neocomplete#enable_camel_case = 1
            let g:neocomplete#enable_auto_delimiter = 1
            let g:neocomplete#auto_completion_start_length = 2
            let g:neocomplete#manual_completion_start_length = 2
            let g:neocomplete#min_keyword_length = 2
            let g:neocomplete#sources#buffer#disabled_pattern = '\.log$\|\.csv$'
            let g:neocomplete#data_directory = $VIMCACHE.'/neocomplete'

            " Custom settings
            call neocomplete#custom#source('ultisnips', 'rank', 100)
            call neocomplete#custom#source('ultisnips', 'min_pattern_length', 1)

            " Sources
            let g:neocomplete#sources = get(g:, 'g:neocomplete#sources', {})
            let g:neocomplete#sources.php = ['omni', 'tag', 'file/include', 'ultisnips']
            let g:neocomplete#sources.html = ['syntax', 'omni', 'file/include', 'ultisnips']
            let g:neocomplete#sources.javascript = ['omni', 'tag', 'file/include', 'ultisnips']
            let g:neocomplete#sources.css = ['omni', 'file/include', 'ultisnips']
            let g:neocomplete#sources.vim = ['omni', 'file/include', 'ultisnips']
            let g:neocomplete#sources.haskell = ['omni', 'file/include', 'ultisnips']

            " Completion patterns
            let g:neocomplete#sources#omni#input_patterns = get(g:, 'g:neocomplete#sources#omni#input_patterns', {})
            let g:neocomplete#sources#omni#input_patterns.php =
                \ '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?\|\(new\|use\|extends\|implements\|instanceof\)\%(\s\|\s\\\)'
            let g:neocomplete#sources#omni#input_patterns.javascript =
                \ '\h\w*\|\h\w*\.\%(\h\w*\)\?\|[^. \t]\.\%(\h\w*\)\?\|\(import\|from\)\s'
            let g:neocomplete#sources#omni#input_patterns.css = '\w*\|\w\+[-:;)]\?\s\+\%(\h\w*\)\?\|[@!]'
            let g:neocomplete#sources#omni#input_patterns.sql = '\h\w*\|[^.[:digit:] *\t]\%(\.\)\%(\h\w*\)\?'
            let g:neocomplete#sources#omni#input_patterns.haskell = '\h\w*\|\(import\|from\)\s'
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('ultisnips')
        call neobundle#config({
        \ 'functions': 'UltiSnips#FileTypeChanged',
        \ 'insert': 1
        \})

        inoremap <silent> ` <C-r>=<SID>ultiComplete()<CR>
        snoremap <C-c> <Esc>

        function! s:ultiComplete()
            if len(UltiSnips#SnippetsInCurrentScope()) >= 1
                return UltiSnips#ExpandSnippet()
            end
            return "\`"
        endfunction

        Autocmd BufNewFile,BufRead *.snippets setl filetype=snippets

        function! neobundle#hooks.on_source(bundle)
            let g:UltiSnipsExpandTrigger = '<S-F12>'
            let g:UltiSnipsListSnippets = '<S-F12>'
            let g:UltiSnipsSnippetsDir = $VIMFILES.'/dev/dotvim/ultisnips'
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('unite.vim')
        call neobundle#config({
        \ 'commands': [
        \   {'name': 'Unite', 'complete': 'customlist,vimfiler#complete'}
        \]})

        " [prefix]b: open buffers
        nnoremap <silent> [prefix]b :<C-u>Unite buffer -toggle<CR>
        " [prefix]h: open windows
        nnoremap <silent> [prefix]h :<C-u>Unite window -toggle<CR>
        " [prefix]t: open tab pages
        nnoremap <silent> [prefix]t
            \ :<C-u>Unite tab -buffer-name=tabs -select=`tabpagenr()-1` -toggle<CR>

        " [prefix]f: open files
        nnoremap <silent> [prefix]f
            \ :<C-u>UniteWithCurrentDir file_rec/async file/new directory/new -start-insert<CR>

        " [prefix]g: grep search
        nnoremap <silent> [prefix]g
            \ :<C-u>Unite grep:. -no-split -auto-preview<CR>
        " [prefix]s: search
        nnoremap <silent> [prefix]s
            \ :<C-u>Unite line:forward:wrap -buffer-name=search-`bufnr('%')` -no-wipe -no-split -start-insert<CR>
        " *: search keyword under the cursor
        nnoremap <silent> *
            \ :<C-u>UniteWithCursorWord line:forward:wrap -buffer-name=search-`bufnr('%')` -no-wipe<CR>
        " [prefix]r: resume search buffer
        nnoremap <silent> [prefix]r
            \ :<C-u>UniteResume search-`bufnr('%')` -no-start-insert -force-redraw<CR>

        " [prefix]o: open message log
        nnoremap <silent> [prefix]x :<C-u>Unite output:message<CR>
        " [prefix]i: NeoBundle update
        nnoremap <silent> [prefix]u :<C-u>Unite neobundle/update
            \ -buffer-name=neobundle -no-split -no-start-insert -multi-line -max-multi-lines=1 -log<CR>

        " Unite tuning
        AutocmdFT unite
            \ setl nolist guicursor=a:blinkon0
            \| Autocmd InsertEnter,InsertLeave <buffer>
                \ setl nonu nornu nolist colorcolumn=

        AutocmdFT unite call <SID>UniteMappings()
            \| imap <buffer> <C-i> <Plug>(unite_insert_leave)

        function! s:UniteMappings()
            " Normal mode
            nmap <buffer> <S-BS>  <Plug>(unite_exit)
            nmap <buffer> <C-BS>  <Plug>(unite_exit)
            nmap <buffer> <S-Tab> <Plug>(unite_loop_cursor_up)
            nmap <buffer> <Tab>   <Plug>(unite_loop_cursor_down)
            nmap <silent> <buffer> <expr> o  unite#do_action('open')
            nmap <silent> <buffer> <expr> ss unite#do_action('split')
            nmap <silent> <buffer> <expr> sv unite#do_action('vsplit')
            nmap <silent> <buffer> <expr> cc unite#do_action('lcd')
            nmap <silent> <buffer> <expr> b  unite#do_action('backup')
            nmap <silent> <buffer> <expr> y  unite#do_action('yank')
            nmap <silent> <buffer> <expr> Y  unite#do_action('yank_escape')

            let unite = unite#get_current_unite()
            if unite.profile_name ==# 'line'
                nmap <silent> <buffer> <expr> r unite#do_action('replace')
            else
                nmap <silent> <buffer> <expr> r unite#do_action('rename')
            endif
            " yankround.vim
            if unite.buffer_name ==# 'yankround'
                nmap <silent> <buffer> o <Enter>
            endif

            " Insert mode
            imap <buffer> <C-BS>  <Plug>(unite_exit)
            imap <buffer> <C-n>   <Plug>(unite_complete)
            imap <buffer> <Tab>   <Plug>(unite_select_next_line)
            imap <buffer> <S-Tab> <Plug>(unite_select_previous_line)
            imap <buffer> <C-a>   <Plug>(unite_move_head)
            imap <buffer> <C-j>   <Plug>(unite_move_left)
            imap <buffer> <C-l>   <Plug>(unite_move_right)
            imap <buffer> <C-p>   <Plug>(unite_delete_backward_path)
            imap <buffer> <C-d>   <Plug>(unite_delete_backward_line)
            imap <buffer> <C-j>   <Plug>(unite_select_next_line)
            imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
            imap <buffer> <S-BS>  <Plug>(unite_delete_backward_line)
            imap <buffer> <expr> <BS> len(getline('.')) > 1 ? "\<Plug>(unite_delete_backward_char)" : ""
            imap <buffer> <expr> <C-e> len(getline('.')) != 1 ? "\<Plug>(unite_delete_backward_char)" : ""
            imap <buffer> <expr> q getline('.')[col('.')-2] ==# 'q' ? "\<Plug>(unite_exit)" : "\q"
        endfunction

        function! neobundle#hooks.on_source(bundle)
            let g:unite_source_history_yank_enable = 0
            let g:unite_source_rec_min_cache_files = 50
            let g:unite_source_buffer_time_format = '%H:%M '
            let g:unite_data_directory = $VIMCACHE.'/unite'

            if executable('ag')
                let g:unite_source_grep_command = 'ag'
                let g:unite_source_grep_recursive_opt = ''
                let g:unite_source_grep_encoding = 'utf-8'
                let g:unite_source_grep_default_opts = '--follow --smart-case --nogroup --nocolor'

                let g:unite_source_rec_async_command = 'ag'
                    \. ' '. join(map(split(g:ignore_pattern, ','), '"\--ignore \"*.".v:val."\""'), ' ')
                    \. (&smartcase ? ' -S' : ''). ' --nogroup --nocolor --hidden -l .'
            endif

            " Default profile
            let s:unite_default = {
            \ 'winheight': 20,
            \ 'direction': 'botright',
            \ 'prompt_direction': 'bellow',
            \ 'cursor_line_time': '0.0',
            \ 'short_source_names': 1,
            \ 'hide_source_names': 1,
            \ 'hide_icon': 0,
            \ 'marked_icon': '+',
            \ 'prompt': '>',
            \ 'wipe': 1
            \}

            " Search profile
            let s:unite_search = {
            \ 'winheight': 20
            \}

            " Quickfix profile
            let s:unite_quickfix = {
            \ 'winheight': 16,
            \ 'no_quit': 1,
            \ 'keep_focus': 1
            \}

            " Custom profiles
            call unite#custom#profile('default', 'context', s:unite_default)
            call unite#custom#profile('source/grep', 'context', s:unite_search)
            call unite#custom#profile('source/quickfix', 'context', s:unite_quickfix)

            " Custom filters
            call unite#filters#sorter_default#use(['sorter_rank'])
            call unite#filters#matcher_default#use(['matcher_fuzzy'])
            call unite#custom#source('buffer', 'sorters', 'sorter_reverse')
            call unite#custom#source('file_rec/async', 'max_candidates', 0)
            call unite#custom#source('file_rec/async', 'matchers',
                \ ['converter_relative_word', 'matcher_fuzzy'])
            call unite#custom#source('source/grep,', 'ignore_globs',
                \ map(split(g:ignore_pattern, ','), '"\*.".v:val.""'))

            hi link uniteStatusHead             StatusLine
            hi link uniteStatusNormal           StatusLine
            hi link uniteStatusMessage          StatusLine
            hi link uniteStatusSourceNames      StatusLine
            hi link uniteStatusSourceCandidates User1
            hi link uniteStatusLineNR           User2
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('neomru.vim')
        call neobundle#config({
        \ 'unite_sources': ['neomru/file', 'neomru/directory'],
        \ 'commands': ['NeoMRUSave', 'NeoMRUReload'],
        \})

        Autocmd BufLeave,VimLeavePre * NeoMRUSave

        " [prefix]l: open recently-opened files
        nnoremap <silent> [prefix]w
            \ :<C-u>call <SID>openMRU(['matcher_fuzzy', 'matcher_project_files', 'matcher_hide_current_file'])<CR>
        " [prefix]L: open recently-opened directories
        nnoremap <silent> [prefix]W
            \ :<C-u>call <SID>openMRU(['matcher_fuzzy', 'matcher_hide_current_file'])<CR>

        function! s:openMRU(matchers)
            call unite#custom#source('neomru/file', 'matchers', a:matchers)
            Unite neomru/file -toggle
        endfunction

        function! neobundle#hooks.on_source(bundle)
            let g:neomru#file_mru_path = $VIMCACHE.'/unite/file'
            let g:neomru#file_mru_ignore_pattern = '\.\%([_]vimrc\|txt\)$'
            let g:neomru#filename_format = ':.'
            let g:neomru#directory_mru_path = $VIMCACHE.'/unite/directory'
            let g:neomru#time_format = '%d.%m %H:%M | '
            " Limit results for recently edited files
            call unite#custom#source('neomru/file,neomru/directory', 'limit', 30)
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('unite-vimpatches')
        call neobundle#config({'unite_sources': 'vimpatches'})

        " [prefix]p: open vimpatches log
        nnoremap <silent> [prefix]U :<C-u>Unite vimpatches -buffer-name=neobundle<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('unite-quickfix')
        call neobundle#config({'unite_sources': 'quickfix'})
        call neobundle#untap()
    endif

    if neobundle#tap('unite-outline')
        call neobundle#config({'unite_sources': 'outline'})

        " [prefix]o: outline
        nnoremap <silent> [prefix]o :<C-u>Unite outline -winheight=16 -silent<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('unite-filetype')
        call neobundle#config({'unite_sources': ['filetype', 'filetype/new']})

        " [prefix]r: filetype change
        nnoremap <silent> [prefix]z :<C-u>Unite filetype filetype/new -start-insert<CR>

        function! neobundle#hooks.on_source(bundle)
            call unite#custom#source('filetype', 'sorters', 'sorter_length')
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('httpstatus-vim')
        call neobundle#config({'unite_sources': 'httpstatus'})

        " F12: http codes
        nnoremap <silent> <F12> :<C-u>Unite httpstatus -start-insert<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('unite-tag')
        call neobundle#config({'unite_sources': ['tag', 'tag/include', 'tag/file']})

        AutocmdFT php,javascript call <SID>UniteTagSettings()
        function! s:UniteTagSettings()
            if empty(&buftype)
                " Ctrl-]: open tag under cursor
                nnoremap <silent> <buffer> <C-]> :<C-u>UniteWithCursorWord tag -immediately<CR>
                " ,t: open tag
                nnoremap <silent> <buffer> ,t :<C-u>UniteWithCursorWord tag tag/include<CR>
                " ,T: search tag by name
                nnoremap <silent> <buffer> ,T :<C-u>call <SID>inputSearchTag()<CR>
            endif
        endfu

        function! s:inputSearchTag()
            let search_word = input(' Tag name: ')
            if search_word != ''
                exe ':Unite tag:'. escape(search_word, '"')
            endif
        endfunction

        call neobundle#untap()
    endif

    if neobundle#tap('vim-qfreplace')
        call neobundle#config({
        \ 'functions': 'qfreplace#start',
        \ 'commands': 'Qfreplace'
        \})

        " qfreplace tuning
        AutocmdFT qfreplace
            \  call feedkeys("\<CR>\<CR>")
            \| setl nonu nornu colorcolumn= laststatus=0
            \| Autocmd BufEnter,WinEnter <buffer> setl laststatus=0
            \| Autocmd BufLeave,BufDelete <buffer> set laststatus=2
            \| Autocmd InsertEnter,InsertLeave <buffer> setl nonu nornu colorcolumn=

        call neobundle#untap()
    endif

" Languages
"---------------------------------------------------------------------------
" Haskell
    " Indent
    AutocmdFT haskell setl nowrap | Indent 4 |
    if neobundle#tap('haskell-indent.vim')
        call neobundle#config({'filetypes': 'haskell'})
        call neobundle#untap()
    endif
    if neobundle#tap('vim-haskell-indent')
        call neobundle#config({'filetypes': 'haskell'})
        call neobundle#untap()
    endif
    " Syntax
    if neobundle#tap('vim-haskellConcealPlus')
        call neobundle#config({'filetypes': 'haskell'})

        AutocmdFT haskell
            \ nnoremap <silent> <buffer> ,c :<C-u>let &l:conceallevel = (&l:conceallevel == 0 ? 2 : 0)<CR>
            \:echo printf(' Conceal mode: %3S (local)', (&l:conceallevel == 0 ? 'Off' : 'On'))<CR>

        call neobundle#untap()
    endif
    if neobundle#tap('vim-syntax-haskell-cabal')
        call neobundle#config({'filename_patterns': '\.cabal$'})
        call neobundle#untap()
    endif
    " Autocomplete
    if neobundle#tap('neco-ghc')
        call neobundle#config({'functions': 'necoghc#omnifunc'})

        AutocmdFT haskell setl omnifunc=necoghc#omnifunc

        function! neobundle#hooks.on_source(bundle)
            let g:necoghc_enable_detailed_browse = 1
        endfunction

        call neobundle#untap()
    endif
    if neobundle#tap('ghcmod-vim')
        call neobundle#config({
        \ 'commands': ['GhcModCheck', 'GhcModLint', 'GhcModCheckAndLintAsync']
        \})

        AutocmdFT haskell Autocmd BufWritePost <buffer> GhcModCheckAndLintAsync
        AutocmdFT haskell
            \  nnoremap <silent> <buffer> ,t :<C-u>GhcModType!<CR>
            \| nnoremap <silent> <buffer> ,T :<C-u>GhcModTypeClear<CR>

        function! neobundle#hooks.on_source(bundle)
            let g:ghcmod_open_quickfix_function = 'GhcModQuickFix'

            function! GhcModQuickFix()
                Unite quickfix -no-empty -silent
            endfunction
        endfunction

        call neobundle#untap()
    endif

" PHP
    " Indent
    AutocmdFT php Indent 4
    if neobundle#tap('PHP-Indenting-for-VIm')
        call neobundle#config({'filetypes': 'php'})
        call neobundle#untap()
    endif
    " Syntax
    let g:php_sql_query = 1
    let g:php_highlight_html = 1
    " Fold
    if neobundle#tap('php-foldexpr.vim')
        call neobundle#config({'filetypes': 'php'})

        AutocmdFT php setl foldenable
            \| let b:phpfold_use = 1
            \| let b:phpfold_group_args = 0
            \| let b:phpfold_group_case = 0
            \| let b:phpfold_group_iftry = 0
            \| let b:phpfold_text = 1
            \| let b:phpfold_text_percent = 0
            \| let b:phpfold_text_right_lines = 1
            \| let b:phpfold_heredocs = 1
            \| let b:phpfold_docblocks = 0
            \| let b:phpfold_doc_with_funcs = 0

        call neobundle#untap()
    endif
    " Autocomplete
    AutocmdFT php setl omnifunc=phpcomplete#CompletePHP
    if neobundle#tap('phpcomplete.vim')
        call neobundle#config({'functions': 'phpcomplete#CompletePHP'})

        function! neobundle#hooks.on_source(bundle)
            let g:phpcomplete_relax_static_constraint = 0
            let g:phpcomplete_parse_docblock_comments = 0
            let g:phpcomplete_search_tags_for_variables = 1
            let g:phpcomplete_complete_for_unknown_classes = 0
            let g:phpcomplete_remove_function_extensions = [
            \ 'apache', 'apc', 'dba', 'dbase', 'odbc', 'msql', 'mssql', 'mysql'
            \]
            let g:phpcomplete_remove_class_extensions = [
            \ 'apc'
            \]
            let g:phpcomplete_remove_constant_extensions = [
            \ 'apc', 'ms_sql_server_pdo', 'msql', 'mssql', 'mysql'
            \]
        endfunction

        call neobundle#untap()
    endif
    " PHP Documentor
    if neobundle#tap('pdv')
        call neobundle#config({
        \ 'functions': ['pdv#DocumentWithSnip', 'pdv#DocumentCurrentLine']
        \})

        AutocmdFT php
            \ nnoremap <silent> <buffer> ,c :<C-u>silent! call pdv#DocumentWithSnip()<CR>

        function! neobundle#hooks.on_source(bundle)
            let g:pdv_template_dir = $VIMFILES.'/dev/dotvim/templates'
        endfunction

        call neobundle#untap()
    endif
    " vDebug (for xDebug)
    if neobundle#tap('vdebug')
        call neobundle#config({'filetypes': 'php'})

        function! neobundle#hooks.on_source(bundle)
            let g:vdebug_options = {
            \ 'port': 9001,
            \ 'server': '10.10.78.16',
            \ 'on_close': 'detach',
            \ 'break_on_open': 1,
            \ 'debug_window_level': 0,
            \ 'watch_window_style': 'compact',
            \ 'path_maps': {'/www': 'D:/Vagrant/projects'},
            \}
            let g:vdebug_features = {
            \ 'max_depth': 2048
            \}

            hi DbgCurrentLine guifg=#2B2B2B guibg=#D2FAC1 gui=NONE
            hi DbgCurrentSign guifg=#2B2B2B guibg=#E4F3FB gui=NONE
            hi DbgBreakptLine guifg=#2B2B2B guibg=#FDCCD9 gui=NONE
            hi DbgBreakptSign guifg=#2B2B2B guibg=#E4F3FB gui=NONE
        endfunction

        call neobundle#untap()
    endif

" JavaScript
    AutocmdFT javascript Indent 2
    " Indent
    if neobundle#tap('simple-javascript-indenter')
        call neobundle#config({'filetypes': 'javascript'})

        function! neobundle#hooks.on_source(bundle)
            let g:SimpleJsIndenter_BriefMode = 1
            let g:SimpleJsIndenter_CaseIndentLevel = -1
        endfunction

        call neobundle#untap()
    endif
    " Syntax
    if neobundle#tap('yajs.vim')
        call neobundle#config({'filetypes': 'javascript'})

        function! neobundle#hooks.on_source(bundle)
            hi link javascriptReserved  Normal
            hi link javascriptInvalidOp Normal
        endfunction

        call neobundle#untap()
    endif
    if neobundle#tap('javascript-libraries-syntax')
        call neobundle#config({'filetypes': ['javascript', 'javascript.jsx']})

        function! neobundle#hooks.on_source(bundle)
            let g:used_javascript_libs = 'react,angularjs,underscore,jquery'
        endfunction

        call neobundle#untap()
    endif
    " Autocomplete
    if neobundle#tap('jscomplete-vim')
        call neobundle#config({'functions': 'jscomplete#CompleteJS'})

        Autocmd BufNewFile,BufRead *.{js,jsx} setl omnifunc=jscomplete#CompleteJS

        function! neobundle#hooks.on_source(bundle)
            let g:jscomplete_use = ['dom', 'moz', 'es6th', 'html5API']
        endfunction

        call neobundle#untap()
    endif
    if neobundle#tap('jscomplete-html5API')
        call neobundle#config({'functions': ['js#html5API#Extend', 'js#webGL#Extend']})
        call neobundle#untap()
    endif
    " JSDoc
    if neobundle#tap('vim-jsdoc')
        call neobundle#config({'mappings': [['n', '<Plug>(jsdoc)']]})

        AutocmdFT javascript,javascript.jsx nmap <buffer> ,c <Plug>(jsdoc)

        function! neobundle#hooks.on_source(bundle)
            let g:jsdoc_allow_shorthand = 1
            let g:jsdoc_allow_input_prompt = 1
            let g:jsdoc_input_description = 1
            let g:jsdoc_additional_descriptions = 0
            let g:jsdoc_return_description = 0
        endfunction

        call neobundle#untap()
    endif
    " Tags
    Autocmd BufNewFile,BufRead *.{js,jsx,javascript.jsx} setl tags=
        \$VIMFILES/tags/js.react/react-0.13.tags
        \,$VIMFILES/tags/js.react/JSXTransformer-0.13.tags

" JSX
    if neobundle#tap('vim-jsx')
        call neobundle#config({'filename_patterns': '\.jsx$'})

        function! neobundle#hooks.on_source(bundle)
            let g:jsx_ext_required = 0
        endfunction

        call neobundle#untap()
    endif

" HTML
    AutocmdFT html Indent 2
    AutocmdFT html iabbrev <buffer> & &amp;
    " Syntax
    if neobundle#tap('html5.vim')
        call neobundle#config({'filetypes': ['html', 'twig', 'htmltwig']})
        call neobundle#untap()
    endif
    if neobundle#tap('MatchTag')
        call neobundle#config({'filetypes': ['html', 'twig', 'htmltwig']})

        AutocmdFT twig,htmltwig runtime! ftplugin/html.vim

        call neobundle#untap()
    endif
    " Autocomplete
    AutocmdFT html setl omnifunc=htmlcomplete#CompleteTags
    if neobundle#tap('emmet-vim')
        call neobundle#config({'mappings': [['i', '<Plug>']]})

        AutocmdFT html,twig,htmltwig,css call <SID>EmmetMappings()

        function! s:emmetComplete()
            if pumvisible()
                return "\<C-n>"
            endif

            if <SID>isBackspace() == 1
                return "\<Tab>"
            endif

            if emmet#isExpandable()
                return emmet#expandAbbr(0, '')
            endif

            call feedkeys("\<C-x>\<C-i>")
            return neocomplete#start_manual_complete()
        endfunction

        function! s:EmmetMappings()
            imap <silent> <buffer> <C-p> <Plug>(emmet-expand-abbr)
            imap <silent> <buffer> <C-q> <Plug>(emmet-expand-word)
            inoremap <silent> <buffer> <Tab> <C-r>=<SID>emmetComplete()<CR>
        endfunction

        function! neobundle#hooks.on_source(bundle)
            let g:user_emmet_mode = 'i'
            let g:user_emmet_complete_tag = 0
        endfunction

        call neobundle#untap()
    endif
    if neobundle#is_installed('vim-closetag')
        let g:closetag_filenames = '*.{html,twig,htmltwig,xml,javascript.jsx}'
    endif

" Twig
    AutocmdFT twig,htmltwig Indent 2
    AutocmdFT twig,htmltwig setl commentstring={#<!--%s-->#}
    " Indent
    if neobundle#tap('twig-indent')
        call neobundle#config({'filename_patterns': ['\.twig$', '\.html.twig$']})
        call neobundle#untap()
    endif
    " Syntax
    if neobundle#tap('vim-twig')
        call neobundle#config({'filename_patterns': ['\.twig$', '\.html.twig$']})

        Autocmd BufNewFile,BufRead *.html.twig set filetype=htmltwig

        call neobundle#untap()
    endif

" CSS
    AutocmdFT css setl iskeyword+=-,%
    " Indent
    AutocmdFT css setl nowrap | Indent 2
    " Syntax
    if neobundle#tap('css.vim')
        call neobundle#config({'filetypes': ['css', 'less']})

        function! neobundle#hooks.on_source(bundle)
            hi link cssError Normal
            hi link cssBraceError Normal
            hi link cssDeprecated Normal
        endfunction

        call neobundle#untap()
    endif
    if neobundle#tap('vim-css3-syntax')
        call neobundle#config({'filetypes': ['css', 'less']})
        call neobundle#untap()
    endif
    " Autocomplete
    AutocmdFT css setl omnifunc=csscomplete#CompleteCSS
    if neobundle#tap('vim-better-css-completion')
        call neobundle#config({'functions': 'csscomplete#CompleteCSS'})
        call neobundle#untap()
    endif
    if neobundle#tap('vim-hyperstyle')
        call neobundle#config({'filetypes': ['css', 'less']})

        Autocmd BufNew,BufEnter,BufWinEnter,WinEnter
            \ *.{css,less} call <SID>HyperstyleMappings()

        function! s:HyperstyleMappings()
            silent! iunmap <buffer> <CR>
            silent! iunmap <buffer> <BS>
            inoremap <silent> <Tab> <C-r>=<SID>neoComplete()<CR>
        endfunction

        call neobundle#untap()
    endif

" LESS
    AutocmdFT less setl nowrap | Indent 2
    " Syntax
    AutocmdFT less setl iskeyword+=-,%
    if neobundle#tap('vim-less')
        call neobundle#config({'filename_patterns': '\.less$'})

        function! neobundle#hooks.on_source(bundle)
            let g:jsx_ext_required = 0
        endfunction

        call neobundle#untap()
    endif

" JSON
    Autocmd BufNewFile,BufRead .{babelrc,eslintrc} Indent 2
    " Syntax
    if neobundle#tap('vim-json')
        call neobundle#config({'filetypes': 'json'})

        AutocmdFT json
            \ nnoremap <silent> <buffer> ,c :<C-u>let &l:conceallevel = (&l:conceallevel == 0 ? 2 : 0)<CR>
            \:echo printf(' Conceal mode: %3S (local)', (&l:conceallevel == 0 ? 'Off' : 'On'))<CR>

        AutocmdFT json setl formatoptions+=2l

        call neobundle#untap()
    endif

" Yaml
    AutocmdFT yaml setl nowrap | Indent 4

" XML
    AutocmdFT xml setl nowrap | Indent 4
    " Autocomplete
    AutocmdFT xml setl omnifunc=xmlcomplete#CompleteTags

" CSV
    if neobundle#tap('csv.vim')
        call neobundle#config({'filename_patterns': '\.csv$'})
        call neobundle#untap()
    endif

" SQL
    if neobundle#tap('vim-sql-syntax')
        call neobundle#config({'filetypes': 'php', 'filename_patterns': '\.sql$'})

        function! neobundle#hooks.on_source(bundle)
            hi link sqlStatement phpStatement
            hi link sqlKeyword   phpOperator
        endfunction

        call neobundle#untap()
    endif

" Nginx
    if neobundle#tap('vim-nginx')
        call neobundle#config({'filename_patterns': '\.conf$'})

        Autocmd BufNewFile,BufRead */nginx/** setl filetype=nginx commentstring=#%s

        call neobundle#untap()
    endif

" Vagrant
    Autocmd BufNewFile,BufRead Vagrantfile setl filetype=ruby

" Docker
    if neobundle#tap('Dockerfile.vim')
        call neobundle#config({'filename_patterns': 'Dockerfile$'})
        call neobundle#untap()
    endif

" Vim
    AutocmdFT vim setl iskeyword+=:
    " Auto reload VimScript
    AutocmdFT vim Autocmd BufWritePost,FileWritePost <buffer> source <afile>

" GUI
"---------------------------------------------------------------------------
    if has('gui_running')
        set guioptions=ac
        set guicursor=n-v:blinkon0  " turn off blinking the cursor
        set linespace=3             " extra spaces between rows
        " Window size and position
        if has('vim_starting')
            winsize 176 34 | winpos 492 326
            " winsize 140 46 | winpos 360 224
        endif
    endif

    " Font
    if s:is_windows
        set guifont=Droid_Sans_Mono:h10,Consolas:h11
    else
        set guifont=Droid\ Sans\ Mono\ 10,Consolas\ 11
    endif

    " DirectWrite
    if s:is_windows && has('directx')
        set renderoptions=type:directx,gamma:2.2,contrast:0.5,level:0.0,geom:1,taamode:1,renmode:3
    endif

" View
"---------------------------------------------------------------------------
    " Don't override colorscheme on reloading
    if !exists('g:colors_name')| silent! colorscheme topos |endif
    " Reload the colorscheme whenever we write the file
    exe 'Autocmd BufWritePost '.g:colors_name.'.vim colorscheme '.g:colors_name

    set shortmess=aoOtTIc
    set formatoptions+=n         " support formatting of numbered lists
    set number relativenumber    " show the line number
    set nocursorline             " highlight the current line
    set hidden                   " allows the closing of buffers without saving
    set switchbuf=useopen,split  " orders to open the buffer
    set showtabline=1            " always show the tab pages
    set noequalalways            " resize windows as little as possible
    set winminheight=0
    set splitbelow splitright

    " Diff
    set diffopt=iwhite,vertical

    " Fold
    set nofoldenable

    " Wrapping
    if exists('+breakindent')
        set wrap                         " wrap long lines
        set linebreak                    " wrap without line breaks
        set breakindent                  " wrap lines, taking indentation into account
        set breakindentopt=shift:4       " indent broken lines
        set breakat=\ \ ;:,!?            " break point for linebreak
        set textwidth=0                  " do not wrap text
        set display+=lastline            " easy browse last line with wrap text
        set whichwrap=<,>,[,],h,l,b,s,~  " end/beginning-of-line cursor wrapping behave human-like
    else
        set nowrap
    endif

    " Highlight invisible symbols
    set nolist listchars=precedes:<,extends:>,nbsp:.,tab:+-,trail:•
    " Avoid showing trailing whitespace when in Insert mode
    let s:trailchar = matchstr(&listchars, '\(trail:\)\@<=\S')
    Autocmd InsertEnter * exe 'setl listchars-=trail:'. s:trailchar
    Autocmd InsertLeave * exe 'setl listchars+=trail:'. s:trailchar

    " Title-line
    set title titlestring=%{MyTitleText()}
    function! MyTitleText()
        let title = []
        let session = fnamemodify(v:this_session, ':t:r')

        if session != ''
            call add(title, '' . session . ' |')
        endif

        let path = substitute(expand('%:p'), $HOME, '~', '')
        call add(title, path == '' ? '[No Name]' : path)

        return join(title, ' ')
    endfunction

    " Command-line
    set cmdheight=1
    set noshowmode   " don't show the mode ('-- INSERT --') at the bottom
    set wildmenu wildmode=longest,full

    " Status-line
    set laststatus=2
    " Format the statusline
    let &statusline =
    \  "%1* %L %*"
    \. "%-0.60f "
    \. "%2*%(%{exists('*BufModified()') ? BufModified() : ''}\ %)%*"
    \. "%="
    \. "%(%{exists('*FileSize()') ? FileSize() : ''}\ %)"
    \. "%2*%(%{&paste ? '[P]' : ''}\ %)%*"
    \. "%2*%(%{&iminsert ? 'RU' : 'EN'}\ %)%*"
    \. "%(%{&fileencoding == '' ? &encoding : &fileencoding}\ %)"
    \. "%2*%(%Y\ %)%*"

    " Status-line functions
    function! BufModified()
        return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
    endfunction

    function! FileSize()
        let bytes = getfsize(expand('%:p'))
        return bytes <= 0 ? '' :
            \ bytes < 1024 ? bytes.'B' : (bytes / 1024).'K'
    endfunction

" Edit
"---------------------------------------------------------------------------
    set report=0           " reporting number of lines changes
    set lazyredraw         " don't redraw while executing macros
    set nostartofline      " avoid moving cursor to BOL when jumping around
    set virtualedit=all    " allows the cursor position past true end of line
    " set clipboard=unnamed  " use * register for copy-paste

    " Keymapping timeout (mapping / keycode)
    set notimeout ttimeoutlen=100

    " Indent
    set cindent          " smart indenting for c-like code
    set autoindent       " indent at the same level of the previous line
    set shiftround       " indent multiple of shiftwidth
    set expandtab        " spaces instead of tabs
    set tabstop=4        " number of spaces per tab for display
    set shiftwidth=4     " number of spaces per tab in insert mode
    set softtabstop=4    " number of spaces when indenting
    set nojoinspaces     " prevents inserting two spaces after punctuation on a join (J)
    " Backspacing setting
    set backspace=indent,eol,start

    " Search
    set hlsearch         " highlight search results
    set incsearch        " find as you type search
    set ignorecase
    set smartcase
    set magic            " change the way backslashes are used in search patterns
    set gdefault         " flag 'g' by default for replacing

    " Autocomplete
    set complete=.
    set completeopt=longest
    set pumheight=14
    " Syntax complete if nothing else available
    Autocmd BufEnter,WinEnter * if &omnifunc == ''| setl omnifunc=syntaxcomplete#Complete |endif

" Shortcuts
"---------------------------------------------------------------------------
    " Insert the current file
    ab ##f <C-r>=expand('%:t:r')<CR>
    ca ##f <C-r>=expand('%:t:r')<CR>
    " Insert the current file path
    ab ##p <C-r>=expand('%:p')<CR>
    ca ##p <C-r>=expand('%:p')<CR>
    " Insert the current file directory
    ab ##d <C-r>=expand('%:p:h').'\'<CR>
    ca ##d <C-r>=expand('%:p:h').'\'<CR>
    " Inset the current timestamp
    ab ##t <C-r>=strftime('%Y-%m-%d')<CR>
    ca ##t <C-r>=strftime('%Y-%m-%d')<CR>
    " Inset the current Unix time
    ab ##l <C-r>=localtime()<CR>
    ca ##l <C-r>=localtime()<CR>
    " Shebang
    ab <expr> #!! '#!/usr/bin/env' . (empty(&filetype) ? '' : ' '.&filetype)

" Normal mode
"---------------------------------------------------------------------------
    " jk: don't skip wrap lines
    nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
    nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
    " Alt-[jkhl]: move selected lines
    nnoremap <silent> <A-j> :<C-u>move+<CR>
    nnoremap <silent> <A-k> :<C-u>move-2<CR>
    nnoremap <A-h> <<<Esc>
    nnoremap <A-h> <<<Esc>
    nnoremap <A-l> >>><Esc>
    " Q: auto indent text
    nnoremap Q ==
    " Y: yank line
    nnoremap Y y$
    " @: record macros
    nnoremap @ q
    " Ctrl-[jk]: scroll up/down
    nnoremap <C-j> <C-d>
    nnoremap <C-k> <C-u>
    " Ctrl-d: duplicate line
    nnoremap <expr> <C-d> 'yyp'. col('.') .'l'
    " [dDcC]: don't update register
    nnoremap d "_d
    nnoremap D "_D
    nnoremap c "_c
    nnoremap C "_C
    nnoremap dd dd
    " nnoremap x "_x
    " nnoremap X "_dd

    " gu: capitalize
    nnoremap gu gUiw`]
    " gr: replace word under the cursor
    nnoremap gr :<C-u>%s/<C-r><C-w>/<C-r><C-w>/g<left><left>
    " g.: smart replace word under the cursor
    nnoremap <silent> g. :<C-u>let @/=escape(expand('<cword>'),'$*[]/')<CR>cgn
    " gl: select last changed text
    nnoremap gl `[v`]
    " gp: select last paste in visual mode
    " nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
    " gv: last selected text operator
    onoremap gv :<C-u>normal! gv<CR>

    " ,<Space>: remove spaces at the end of lines
    nnoremap <silent> ,<Space> :<C-u>FixWhitespace<CR>
    " Ctrl-c: old clear highlight after search
    nnoremap <silent> <C-c> :<C-u>nohl<CR>:let @/=""<CR>
    " [N]+Enter: jump to a line number or mark
    nnoremap <silent> <expr> <Enter> v:count ?
        \ ':<C-u>call cursor(v:count, 0)<CR>zz' : "\'"

    " Files
    "-----------------------------------------------------------------------
    " ,ev: open .vimrc in a new tab
    nnoremap <silent> ,ev :<C-u>tabnew $MYVIMRC<CR>
    " Ctrl-Enter: save file
    nnoremap <silent> <C-Enter> :<C-u>write!<CR>
    " Shift-Enter: force save file
    nnoremap <silent> <S-Enter> :<C-u>update!<CR>
    " <Space>e: reopen file
    nnoremap <silent> <Space>o :<C-u>edit!<CR>

    " Buffers
    "-----------------------------------------------------------------------
    " <Space>A: previous buffer
    nnoremap <silent> <Space>A :<C-u>bnext<CR>
    " <Space>E: next buffer
    nnoremap <silent> <Space>E :<C-u>bprev<CR>
    " <Space>d: delete buffer
    nnoremap <silent> <Space>d :<C-u>bdelete<CR>
    " <Space>D: force delete buffer
    nnoremap <silent> <Space>D :<C-u>bdelete!<CR>

    " Tabs
    "-----------------------------------------------------------------------
    " <Space>1-9: jumps to a tab number
    for n in range(1, 9)
        exe printf('nnoremap <silent> <Space>%d %dgt', n, n)
    endfor | unlet n
    " <Space>a: previous tab
    nnoremap <silent> <Space>a :<C-u>tabprev<CR>
    " <Space>e: next tab
    nnoremap <silent> <Space>e :<C-u>tabnext<CR>
    " [N]+<Space>c: close tab
    nnoremap <silent> <expr> <Space>c v:count
        \ ? ':<C-u>'.v:count.'tabclose<CR>'
        \ : ':<C-u>tabclose<CR>'
    " [N]+<Space>C: force close tab
    nnoremap <silent> <expr> <Space>c v:count
        \ ? ':<C-u>'.v:count.'tabclose!<CR>'
        \ : ':<C-u>tabclose!<CR>'
    nnoremap <silent> <Space>C :<C-u>tabclose!<CR>
    " <Space>o: tab only
    nnoremap <silent> <Space>o :<C-u>tabonly<CR>
    " <Space>m: tab move
    nnoremap <silent> <Space>m :<C-u>tabmove<CR>
    " <Space>t: tab new
    nnoremap <silent> <Space>t :<C-u>tabnew<CR>
    " <Space>T: tab new and move
    nnoremap <silent> <Space>T :<C-u>tabnew<CR>:tabmove<CR>
    " <Space><: move tab to first spot
    nnoremap <silent> <Space>< :<C-u>tabmove 0<CR>
    " <Space>>: move tab to last spot
    nnoremap <silent> <expr> <Space>> ':<C-u>tabmove '.tabpagenr('$').'<CR>'
    " <Space>,: move tab to left
    nnoremap <silent> <expr> <Space>,
        \ ':<C-u>tabmove '.max([tabpagenr() - v:count1 - 1, 0]).'<CR>'
    " <Space>.: move tab to right
    nnoremap <silent> <expr> <Space>.
        \ ':<C-u>tabmove '.min([tabpagenr() + v:count1, tabpagenr('$')]).'<CR>'

    " Windows
    "-----------------------------------------------------------------------
    for s in ['h', 'j', 'k', 'l']
        " <Space>[hjkl]: jump to a window
        exe printf('nnoremap <silent> <Space>%s :<C-u>wincmd %s<CR>', s, s)
        " <Space>[HJKL]: move the current window
        exe printf('nnoremap <silent> <Space>%s :<C-u>wincmd %s<CR>', toupper(s), toupper(s))
    endfor | unlet s
    " <Space>w: next window
    nnoremap <silent> <Space>w :<C-u>wincmd w<CR>
    " <Space>W: previous window
    nnoremap <silent> <Space>W :<C-u>wincmd W<CR>
    " <Space>r: rotate windows downwards/rightwards
    nnoremap <silent> <Space>r :<C-u>wincmd r<CR>
    " <Space>R: rotate windows upwards/leftwards
    nnoremap <silent> <Space>R :<C-u>wincmd R<CR>
    " <Space>n: set current window to highest possible
    nnoremap <silent> <Space>n :<C-u>wincmd _<CR>
    " <Space>b: make all windows (almost) equally high and wide
    nnoremap <silent> <Space>b :<C-u>wincmd =<CR>
    " >: increase current window height
    nnoremap <silent> > :<C-u>resize +3<CR>
    " <: decrease current window height
    nnoremap <silent> < :<C-u>resize -3<CR>
    " <Space>m: move window to a new tab page
    nnoremap <silent> <Space>m :<C-u>wincmd T<CR>
    " <Space>q: smart close window -> tab -> buffer
    nnoremap <silent> <expr> <Space>q winnr('$') == 1
        \ ? printf(':<C-u>%s<CR>', (tabpagenr('$') == 1 ? 'bdelete!' : 'tabclose!'))
        \ : ':<C-u>close<CR>'
    " <Space>Q: force smart close window -> tab -> buffer
    nnoremap <silent> <expr> <Space>Q winnr('$') == 1
        \ ? printf(':<C-u>%s<CR>', (tabpagenr('$') == 1 ? 'bdelete!' : 'tabclose!'))
        \ : ':<C-u>close!<CR>'
    " <Space>s: split window horizontaly
    nnoremap <silent> <Space>s :<C-u>split<CR>
    " <Space>S: split window verticaly
    nnoremap <silent> <Space>S :<C-u>vertical split<CR>

    " Unbinds
    map <F1> <Nop>
    " map K <Nop>
    map ZZ <Nop>
    map ZQ <Nop>

" Insert mode
"---------------------------------------------------------------------------
    " Alt-[jkhl]: standart move
    imap <A-j> <C-o>gj
    imap <A-h> <C-o>h
    imap <A-k> <C-o>gk
    imap <A-l> <C-o>l
    " Ctrl-a: jump to head
    inoremap <C-a> <C-o>I
    " Ctrl-e: jump to end
    inoremap <C-e> <C-o>A
    " Ctrl-b: jump back to beginning of previous wordmp to first char
    inoremap <C-q> <Home>
    " Ctrl-<BS>: delete word
    inoremap <C-d> <BS>
    " Ctrl-f: delete next char
    inoremap <C-f> <Del>
    " Ctrl-Enter: break line below
    inoremap <C-CR> <Esc>O
    " Shift-Enter: break line above
    inoremap <S-CR> <C-m>
    " jj: fast Esc
    inoremap <expr> j getline('.')[col('.')-2] ==# 'j' ? "\<BS>\<Esc>`^" : 'j'
    " Ctrl-l: fast Esc
    inoremap <C-l> <Esc>`^
    " Ctrl-c: old fast Esc
    inoremap <C-c> <Esc>`^
    " Ctrl-_: undo
    inoremap <C-_> <C-o>u
    " Ctrl-p: paste
    imap <C-p> <S-Insert>
    " Ctrl+s: force save file
    inoremap <silent> <C-s> <Esc> :write!<CR>i
    " Alt+w: force save file
    inoremap <silent> <A-w> <Esc> :write!<CR>i
    " Alt-q: change language
    inoremap <A-q> <C-^>
    " qq: smart fast Esc
    imap <expr> q getline('.')[col('.')-2] ==# 'q' ? "\<BS>\<Esc>`^" : 'q'

" Visual mode
"---------------------------------------------------------------------------
    " jk: don't skip wrap lines
    xnoremap <expr> j (v:count == 0 && mode() !=# 'V') ? 'gj' : 'j'
    xnoremap <expr> k (v:count == 0 && mode() !=# 'V') ? 'gk' : 'k'
    " Alt-[jkhl]: move selected lines
    xnoremap <silent> <A-j> :move'>+<CR>gv
    xnoremap <silent> <A-k> :move-2<CR>gv
    xnoremap <A-h> <'[V']
    xnoremap <A-l> >'[V']
    " L: move to end of line
    xnoremap L $h
    " Q: auto indent text
    xnoremap Q ==<Esc>
    " <Space>: fast Esc
    snoremap <Space> <Esc>
    xnoremap <Space> <Esc>
    " Alt-w: fast save
    xmap <silent> <A-w> <Esc> :update<CR>
    " Ctrl-s: old fast save
    xmap <C-s> <Esc> :write!<CR>
    " Ctrl-[jk]: scroll up/down
    xnoremap <C-j> <C-d>
    xnoremap <C-k> <C-u>
    " .: repeat command for each line
    vnoremap . :normal .<CR>
    " @: repeat macro for each line
    vnoremap @ :normal @
    " [yY]: keep cursor position when yanking
    xnoremap <silent> <expr> y 'ygv'. mode()
    xnoremap <silent> <expr> Y 'Ygv'. mode()
    " Ctrl-c: copy
    xnoremap <C-c> y`]
    " <BS>: delete selected and go into insert mode
    xnoremap <BS> c
    " p: paste not replace the default register
    xnoremap p "_dP
    " [dDcC]: delete to black hole register
    xnoremap d "_d
    xnoremap D "_D
    xnoremap c "_c
    xnoremap C "_C
    " xnoremap x "_x
    " xnoremap X "_X

" Command mode
"---------------------------------------------------------------------------
    " Ctrl-h: previous char
    cnoremap <C-h> <Left>
    " Ctrl-l: next char
    cnoremap <C-l> <Right>
    " Ctrl-h: previous word
    cnoremap <A-h> <S-left>
    " Ctrl-h: next word
    cnoremap <A-l> <S-right>
    " Ctrl-j: previous history
    cnoremap <C-j> <Down>
    " Ctrl-k: next history
    cnoremap <C-k> <Up>
    " Ctrl-d: delete char
    cnoremap <C-d> <Del>
    " Ctrl-a: jump to head
    cnoremap <C-a> <Home>
    " Ctrl-e: jump to end
    cnoremap <C-e> <End>
    " Ctrl-v: open the command-line window
    cnoremap <C-v> <C-f>a
    " jj: smart fast Esc
    cnoremap <expr> j getcmdline()[getcmdpos()-2] ==# 'j' ? "\<C-c>" : 'j'
    " qq: smart fast Esc
    cnoremap <expr> q getcmdline()[getcmdpos()-2] ==# 'q' ? "\<C-c>" : 'q'
    " `: old fast Esc
    cnoremap <silent> ` <C-c>

" Experimental
"---------------------------------------------------------------------------
    " ,p: toggle paste mode
    nnoremap <silent> ,p :<C-u>let &paste = !&paste<CR>
        \:echo printf(' Paste mode: %3S (global)', (&paste == 1 ? 'On' : 'Off'))<CR>

    " ,o: toggle wrapping of text (local)
    nnoremap <silent> ,o :<C-u>let &l:wrap = !&l:wrap<CR>
        \:echo printf(' Wrap mode: %3S (local)', (&l:wrap == 1 ? 'On' : 'Off'))<CR>
    " ,O: toggle wrapping of text (global)
    nnoremap <silent> ,O :<C-u>let &wrap = !&wrap<CR>
        \:echo printf(' Wrap mode: %3S (global)', (&wrap == 1 ? 'On' : 'Off'))<CR>

    " [nN]: append blank line and space
    nnoremap <silent> <expr> n v:count ?
        \ ":\<C-u>for i in range(1, v:count1) \| call append(line('.'), '') \| endfor\<CR>" : 'i<Space><Esc>'
    nnoremap <silent> <expr> N v:count ?
        \ ":\<C-u>for i in range(1, v:count1) \| call append(line('.')-1, '') \| endfor\<CR>" : 'i<Space><Esc>`^'

    " ): jump to next pair
    nnoremap ) f)
    " (: jump to previous pair
    nnoremap ( F(

    " #: keep search pattern at the center of the screen
    nnoremap <silent># #zz

    " ,yn: copy file name to clipboard (foo/bar/foobar.c => foobar.c)
    nnoremap <silent> ,yn :<C-u>let @*=fnamemodify(bufname('%'),':p:t')<CR>

    " Inspect syntax
    nnoremap ,i :<C-u>echo map(synstack(line('.'), col('.')), 'synIDattr(synIDtrans(v:val), "name")')<CR>

    " [#*]: make # and * work in visual mode too
    vnoremap # y?<C-r>*<CR>
    vnoremap * y/<C-r>*<CR>

    " ,r: replace a word under cursor
    nnoremap ,r :%s/<C-R><C-w>/<C-r><C-w>/g<left><left>
    xnoremap re y:%s/<C-r>=substitute(@0, '/', '\\/', 'g')<CR>//gI<Left><Left><Left>

    " R: replace
    function! s:replace()
        if visualmode() ==# 'V'
            if line("'>") == line('$')
                normal! gv"_dp
            else
                normal! gv"_dP
            endif
        else
            if col("'>") == col('$') - 1
                normal! gv"_dp
            else
                normal! gv"_dP
            endif
        endif
    endfunction
    xnoremap R "_dP
    xnoremap <silent> R :<C-u>call <SID>replace()<CR>
