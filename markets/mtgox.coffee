module.exports = mtgox = (market) ->
	Mtgox = require 'mtgox'
	gox = new Mtgox()

	(next) ->
		gox.depth 'BTC'+market, (err,depth) ->
			return next err if err
			
			transform = (x) ->
				{price,volume} = x
				[ price + ' '+market, volume + ' btc' ]
			bid = depth.bids.map transform
			ask = depth.asks.map transform
			next null, 'mtgox:' + market, bids:bid, asks:ask, fee:0.6