_ = require 'underscore'
MA = require 'moving-average'
parse = require './parse'

module.exports = Spread = (sources,timeInterval,currencies) ->

	xrate = {}

	go = (a,b,next) ->
		request = require 'request'
		cheerio = require 'cheerio'
		request 'https://www.google.com/finance?q=' + a + b, (err,res,body) ->
			return next err if err
			$ = cheerio.load body
			try
				next null, (parse $('.bld').text())[0]
			catch e
				console.log String(e)
				next 500

	currencies.forEach (a,i) ->
		xrate[a] ?= {}
		currencies.forEach (b,j) ->
			return if j<=i
			
			retry = ->
				go a,b,(err,r) ->
					unless err
						xrate[a][b] = r
						throw new Error('currency should be sorted to preserve accuracy') if r < 0.25
					setTimeout retry, 10000
			retry()

	add = (a,b) -> a + b
	sub = (a,b) -> a - b
	div = (a,b) -> a / b

	xrated = (fn) ->
		(a,b) ->
			if a[1] == b[1]
				[fn(a[0],b[0]),a[1]]
			else
				xch = xrate[a[1]]?[b[1]]
				if xch?
					[ fn(xch * a[0], b[0]), b[1] ]
				else
					xch = xrate[b[1]]?[a[1]]
					if xch?
						[ fn(a[0], xch * b[0]), a[1] ]
					else
						throw new Error("????!?!?!")

	add = xrated add
	sub = xrated sub
	_xdiv = xrated(div)
	div = (a,b) ->
		[ _xdiv(a,b)[0] * 100, '%' ]

	matrix = (M,fn) ->
		keys = _.keys(M)
		end = keys.length-1
		for i in [0..end] by 1
			for j in [i+1..end] by 1
				a = keys[i]
				b = keys[j]
				fn a, b, M[a], M[b]
	spread = {}

	sources.on 'update', (name,result) ->
		console.log name.bold.red
		# _.keys(sources.data).forEach (k) ->
		# 	a = sources.data[k]
		# 	console.log k, 'ask:',a.asks[0..2], 'bid:',a.bids[0..2]
		matrix sources.data, (name_a, name_b, a,b) ->
			try
				test = (a,b) ->
					buy = b.asks[0][0].slice()
					bought = (1-b.fee/100)

					sell = a.bids[0][0].slice()
					sell[0] *= bought * (1-a.fee/100)

					profit = sub(sell,buy)
					roi = div(profit,buy)
					[ roi, profit, buy, sell ]
				fwd = test(b,a)
				bwd = test(a,b)

				now = Date.now()
				add = (name_a,name_b,fwd) ->
					spread[name_a] ?= []
					spread[name_a][name_b] ?= {ma:(timeInterval.map (ti) -> MA ti),last:0}
					spread[name_a][name_b].ma.forEach (ma) -> ma.push now, fwd[0][0]
					spread[name_a][name_b].last = fwd[0][0]

				add name_a, name_b, fwd
				add name_b, name_a, bwd
			catch e
				# console.log String(e).bold.yellow
				# console.log e.stack

			# if add(bwd[0],fwd[0])[0] > 0
			# 	console.log '->', bwd...
			# 	console.log '<-', fwd...
			# else
			# 	console.log 'failed ->', bwd...
			# 	console.log 'failed <-', fwd...
	sources:sources
	spread:spread