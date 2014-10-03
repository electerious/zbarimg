fs		= require 'fs'
process	= require 'child_process'

module.exports = (photo, callback) ->

	stdout	= ''
	stderr	= ''
	killed	= false

	# Catch missing parameter
	if	not photo? or
		not callback? or
		photo.length is 0

			err = new Error 'Missing parameter'
			callback err, null
			return false

	# Run zbarimg
	zbarimg = process.spawn 'zbarimg', [photo, '-q']

	zbarimg.stdout.setEncoding 'utf8'
	zbarimg.stderr.setEncoding 'utf8'

	zbarimg.stdout.on 'data', (data) ->
		stdout += data

	zbarimg.stderr.on 'data', (data) ->
		stderr += data

	zbarimg.on 'error', (err) ->

		# Avoid fn called twice
		return false if killed is true
		killed = true

		callback err, null
		return true

	zbarimg.on 'close', (code) ->

		# Avoid fn called twice
		return false if killed is true
		killed = true

		if stdout?

			if stdout.indexOf('QR-Code:') isnt -1

				stdout = stdout.replace 'QR-Code:', '' # Remove type
				stdout = stdout.slice 0, -1 # Remove \n
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