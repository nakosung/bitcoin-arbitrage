module.exports = T = ->
	BTCE = require 'btce'
	btce = new BTCE()
	
	(next) ->
		btce.depth {}, (err,depth) ->
			return next err if err

			transform = (x) ->
				[a,b] = x
				["#{a} usd","#{b} btc"]
			bid = depth.bids.map transform
			ask = depth.asks.map transform
			next null, 'btce', bids:bid, asks:ask, fee:0.2

T() ->