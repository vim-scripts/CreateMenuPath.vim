" -----------------------------------------------------------------------------
"
" CreateMenuPath Version 1.2
"
" Create a menu that mirrors a directory tree.
"
" Usage:
" CreateMenuPath({path} [, {menu name} [, {menu priority} [, {filename ignore pattern}]]])
"
" Default menu name is "Files", no default priority.
" A default filename ignore pattern is provided, but is far from "complete".
"
" Requires at least Vim6 to run.
"
" -----------------------------------------------------------------------------

function! CreateMenuPath(path, ...)

	let priority = ''
	let menuname = 'Files'
	let ignore_pat = '\%\(\CRCS\|CVS\|\.\%\(\c'
		\ . 'png\|gif\|jpe\=g\|ico\|bmp\|tiff\='
		\ . '\|mpg\|mov\|avi\|rm\|qt'
		\ . '\|zip\|tar\|tar\.gz\|tgz\|tar\.bz2'
		\ . '\|mp[32]\|wav\|au\|ogg\|mid'
		\ . '\|exe'
		\ . '\)\)$'

	if a:0 >= 1
		let menuname = a:1
	endif
	if a:0 >= 2
		let priority = a:2
	endif
	if a:0 == 3
		let ignore_pat = a:3
	elseif a:0 > 3
		echoerr 'Too many arguments.'
		return
	endif

	silent! exe 'unmenu ' . menuname
	silent! exe 'unmenu! ' . menuname

	let originalpriority = priority
	let originalmenuname = menuname

	let files=glob(a:path . "/*")

	if files == ""
		return
	endif

	" Shortcut key list (C, R and M will be used elsewhere, so don't include
	" them):
	let shortcutlist = '1234567890ABDEFGHIJKLNOPQSTUVWXYZ'

	" Don't mess with this:
	let subpriority = 20

	let start = 0
	let match = 0
	let i = 0

	while (match != -1)

		let match = match(files, "\n", start)
		if match == -1
			let fullfile = strpart(files, start)
		else
			let fullfile = strpart(files, start, match - start)
			let start = match + 1
		endif

		if match(fullfile, ignore_pat) > -1
			continue
		endif

		if i >= 29 && match > -1
			let menuname = menuname . '.\.\.\.&More'
			let priority = priority . '.' . subpriority
			let subpriority = 20
			let i = 0
		else
			let subpriority = subpriority + 10
		endif

		let file = escape(fnamemodify(fullfile, ':t'), "\\. \t|")

		if isdirectory(fullfile)
			call CreateMenuPath(
				\ fullfile,
				\ menuname . '.' . '&' . shortcutlist[i] . '\.\ \ ' . file,
				\ priority . '.' . subpriority,
				\ ignore_pat
			\)
		else
			exe 'amenu ' . priority . '.' . subpriority
				\ . ' ' . menuname . '.' . '&' . shortcutlist[i] . '\.\ \ ' . file
				\ . ' :confirm e ' . escape(fullfile, ' |"') . '<CR>'
		endif

		let i = i + 1

	endwhile

	" Add cd/rescan items to this menu, if any files/submenus appeared in it:
	if subpriority > 20
		exe 'amenu ' . originalpriority . '.10'
			\ . ' ' . originalmenuname . '.&CD\ Here'
			\ . ' :cd ' . escape(a:path, ' |"') . '<CR>'
		exe 'amenu <silent> ' . originalpriority . '.20'
			\ . ' ' . originalmenuname . '.&Rescan'
			\ . " :call CreateMenuPath('"
				\ . a:path . "', '"
				\ . originalmenuname . "', '"
				\ . originalpriority . "', '"
				\ . escape(ignore_pat, '|') .
			\ "')<CR>"
		exe 'menu ' . originalpriority . '.25' . ' ' . originalmenuname . '.-sep1- <nul>'
	endif

endfunction
