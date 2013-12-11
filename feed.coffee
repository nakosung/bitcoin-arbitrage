events = require 'events'
_ = require 'underscore'
parse = require './parse'

module.exports = ->
	sources = new events.EventEmitter()
	sources.data = {}

	feed = (worker,interval = 1000) ->
		cycle = ->
			worker (err,name,result) ->
				unless err
					# console.log name,result
					result.bids = result.bids.map (x) -> 
						[a,b] = x
						[parse(a),b]
					result.asks = result.asks.map (x) -> 
						[a,b] = x
						[parse(a),b]
					# bids are sorted in descending order
					# asks are sorted in ascending order 
					result.bids = _.sortBy result.bids, (x) -> -x[0][0]
					result.asks = _.sortBy result.asks, (x) -> x[0][0]

					sources.data[name] = result
					sources.emit 'update', name, result

				setTimeout cycle, interval
		cycle()

	sources : sources
	feed : feed