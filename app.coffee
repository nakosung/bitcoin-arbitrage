# 

colors = require 'colors'
_ = require 'underscore'
timeInterval = [5 * 1000 * 60, 60 * 1000 * 60, 24 * 60 * 1000 * 60, 7 * 24 * 3600 * 1000]

{sources,feed} = (require './feed')()
dummy = (name,ask,bid,fee) ->
	(next) ->
		next null, name, asks:[[ask,1]], bids:[[bid,1]], fee:fee

markets = require './markets'

feed markets.mtgox('USD')
feed markets.mtgox('EUR')
feed markets.mtgox('JPY')
feed markets.bitstamp()
feed markets.korbit()
feed markets.btcchina()
feed markets.btce()
# feed dummy 'A', '100 usd', '100 usd', 0.5
# feed dummy 'B', '100 usd', '100 usd', 0.5


Spread = require './spread'
		
dump = require './dump'

currencies = 'eur usd cny jpy krw'.split(' ')

setInterval dump.bind(null,Spread(sources,timeInterval,currencies),timeInterval), 250