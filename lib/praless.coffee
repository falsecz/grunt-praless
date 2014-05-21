less = require 'less'
fs = require 'fs'

exports.parse = (files, importBase, base, done) ->


	map = {}
	fileMap = {}
	registerParent = (parent, file) ->
		map[parent] ?= {}
		if map[parent].file
			throw new Error "#{parent} redefining parent #{file} <> #{map[parent].file}"
		map[parent].deps = []
		map[parent].file = file

	addDependency = (parent, dependency) ->
		map[parent].deps.push dependency

	for file in files
		data = fs.readFileSync file, 'utf-8'

		provides = []
		r = new RegExp /^\s*\@provide \s*[\'"](.+)[\'"]/gm

		while m = r.exec data
			registerParent m[1], file
			provides.push m[1]

		r = new RegExp /^\s*\@require \s*[\'"](.+)[\'"]/gm
		while m = r.exec data
			fileMap[file] ?= []
			fileMap[file].push m[1]

			for provide in provides
				addDependency provide, m[1]


	# data = ""
	lineMap = []
	lineIndex = 1

	less2css = (ns) ->
		data = ""
		unless map[ns]
			throw new Error "Missing namespace: #{ns}"
			return data
		# console.log "NS: ", ns, map[ns]

		for dep in map[ns].deps
			data += less2css dep

		unless map[ns].read
			file = map[ns].file
			source = fs.readFileSync file, "utf-8"
			lineIndex++
			for line, i in source.split '\n'
				lineMap[lineIndex++] =
					file: file
					line: i + 1

			data += "/* @@@@@ #{file} */ \n#{source}\n"
			map[ns].read = yes


		data
	try
		data = less2css base
	catch err
		return done err

	# As of LESS 1.7.0 disallows unknown directives, we have to comment them out (will be remove at final output)
	data = data.replace /(@(require|provide|include)\b)/g, "//$1"

	# console.log importBase
	parser = new less.Parser
		paths: importBase

	bindError = (err) ->
		item = lineMap[err.line]
		err.filename = item.file
		err.line = item.line
		err

	parser.parse data, (err, tree) ->
		if err
			return done bindError err
		try
			done null, tree.toCSS()
		catch err
			return done bindError err




