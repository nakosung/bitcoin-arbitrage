module.exports = bitstamp = ->
	Bitstamp = require 'bitstamp'
	bitstamp = new Bitstamp
	
	(next) ->
		bitstamp.order_book (err,depth) ->
			return next err if err

			transform = (x) ->
				[a,b] = x
				["#{a} usd","#{b} btc"]
			bid = depth.bids.map transform
			ask = depth.asks.map transform
			next null, 'bitstamp', bids:bid, asks:ask, fee:0.5
