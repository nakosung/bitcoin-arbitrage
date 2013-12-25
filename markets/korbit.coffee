korbit = require 'korbit'
module.exports = ->
	(next) ->
		korbit.depth (err,depth) ->
			return next err if err

			depth.fee = 0.6

			next null, 'korbit', depth
