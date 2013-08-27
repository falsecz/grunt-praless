praless = require '../lib/praless'

module.exports = (grunt) ->
	formatLessError = (e) ->
		pos = '[' + 'L' + e.line + ':' + ('C' + e.column) + ']'
		e.filename + ': ' + pos + ' ' + e.message

	lessError = (e) ->
		console.log e
		message = formatLessError(e)

		grunt.log.error message
		grunt.fail.warn 'Error compiling LESS.'



	grunt.registerMultiTask 'praless', 'Compile LESS files to CSS', () ->
		done = @async()

		options = @options
			importBase: ["."]

		grunt.verbose.writeflags options, 'Options'

		unless @files.length
			grunt.verbose.warn 'Destination not written because no source files were provided.'

		files = @files.map (item) -> item.src[0]

		praless.parse files, options.importBase, options.base, (err, css) ->
			if err
				lessError err
				done err
				return

			grunt.file.write options.dest, css
			# console.log options
			grunt.log.writeln 'File ' + options.dest + ' created.'
			done()


