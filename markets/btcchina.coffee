module.exports = btcchina = ->
	request = require 'request'

	(next) ->
		request 'http://data.btcchina.com/data/ticker', (err,res,body) ->
			return next err if err

			try
				{ticker} = JSON.parse body
				{buy,sell} = ticker

				buy += ' cny'
				sell += ' cny'

				next null, 'btcchina', bids:[[buy,'1 btc']], asks:[[sell,'1 btc']], fee:0.5
			catch e
				next 500
