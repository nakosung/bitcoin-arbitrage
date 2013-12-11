module.exports = parse = (x) ->
	[n,unit] = x.split(' ')
	n = parseFloat n.replace /,/g, ''
	unit = unit.toLowerCase()
	[n,unit]
