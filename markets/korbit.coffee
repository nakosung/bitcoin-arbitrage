module.exports = korbit = ->
	request = require 'request'
	cheerio = require 'cheerio'

	(next) ->
		request 'https://www.korbit.co.kr', (err,res,body) ->
			return next err if err

			$ = cheerio.load body
			span5 = $('.span5.offset1').next()
			bids = []
			asks = []
			$('tr',span5).slice(2).each (i,elem) ->
				[bid_b,bid_a,ask_a,ask_b] = $('td',@).map -> $(@).text()
				bids.push [bid_a,bid_b]
				asks.push [ask_a,ask_b]

			# console.log $('tr',table).html()
			next null, 'korbit', bids:bids, asks:asks, fee:1
