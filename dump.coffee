_ = require 'underscore'

module.exports = dump = (Spread,timeInterval) ->
	{spread,sources} = Spread
	console.log '\x1b[2J\x1b[0;0HSearching for bitcoin arbitrage opportunity'
	console.log ''
	fmt = (s,L=12) ->
		(s + '                                 ').substr(0,L)
	fmtN = (s,L=8) ->
		s = s.toFixed(2)
		s = ('                                 ' + s)
		s.substr(s.length-L,L)
	fmtN_sig = (s,L=8) ->
		t = fmtN(s,L)
		if s > 0
			t.bold.green
		else if s < 0
			t.bold.red
		else
			(fmtN 0,L).replace /0/g, ' '
	sum_pct = (a,b) ->
		(((1 + a/100) * (1 + b/100)) - 1) * 100

	final = {}
	for k,v of spread
		F = final[k] = {}
		for kk,vv of v
			F[kk] = O = {}
			ma = vv.ma.map (ma) -> ma.movingAverage()
			diff = ma.map (ma) -> vv.last - ma
			x = ma.map (ma,i) -> fmtN(ma) + fmtN_sig(diff[i]) + fmtN_sig(sum_pct(vv.last,spread[kk][k].ma[i].movingAverage()))

			O.last = fmtN_sig(vv.last,8) + fmt('',16)
			O.ma = x

			# console.log fmt(k), fmt(kk), x.join(''), fmtN(vv.last)
	console.log fmt(''), (_.keys(final).map (x) -> fmt(x,24)).join('')
	for k,v of final
		line = fmt(k)
		ma_lines = timeInterval.map -> fmt('')
		_.keys(final).forEach (f) ->
			vv = v[f] 
			if vv?
				line += vv.last
				ma_lines = ma_lines.map (ma,i) ->
					ma + vv.ma[i]
			else
				line += fmt('',24)
				ma_lines = ma_lines.map (ma) -> ma + fmt('',24)
		console.log line
		ma_lines.forEach (l) -> console.log l
	console.log ''
	console.log ''

	for k,v of sources.data
		console.log fmt(k), 'ask:', fmt(v.asks[0]?[0].join(''),20), 'bid:', fmt(v.bids[0]?[0].join(''),20)