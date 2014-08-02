fs		= require 'fs'
process	= require 'child_process'

escapeshell = (cmd) ->

	return '"' + cmd.replace(/(["'$`\\])/g,'\\$1') + '"';

module.exports = (photo, callback) ->

	# Catch missing parameter
	if	not photo? or
		not callback? or
		photo.length is 0

			err = new Error 'Missing parameter'
			callback err, null
			return false

	# Escape
	photo = escapeshell photo

	# Run zbarimg
	zbarimg = process.exec "zbarimg #{ photo } -q", (err, stdout, stderr) ->

		if err?

			callback err, null
			return false

		if stdout?

			if stdout.indexOf('QR-Code:') isnt -1

				stdout = stdout.replace 'QR-Code:', '' # Remove type
				stdout = stdout.slice 0, -2 # Remove \n
				callback null, stdout
				return true

			else

				err = new Error 'No QR-Code found or barcode not supported'
				callback err, null
				return false

		if stderr?

			err = new Error stderr
			callback err, null
			return false