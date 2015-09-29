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

			codeName = stdout.slice 0, (stdout.indexOf(':') + 1) # Can be 'QR-Code:' or 'EAN-13:' or anything else (ask expert)

			if codeName.length > 0

				stdout = stdout.replace codeName, '' # Remove type
				stdout = stdout.slice 0, -1 # Remove \n
				callback null, stdout
				return true

			else

				err = new Error 'No code found or barcode is not supported'
				callback err, null
				return false

		if stderr?

			err = new Error stderr
			callback err, null
			return false