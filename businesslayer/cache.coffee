dslActionHelper = require('./dslActionHelper')

exports.most_collected = (callback) ->
	console.log('start cache most_collected')
	dslActionHelper.executeAction {__data:{}, __returnData:{}}, {}, 'most_collected_cache', (err, resultSet) ->
		callback resultSet
		console.log 'finished cache most_collected'

exports.most_played = (callback) ->
	console.log('start cache most_played')
	dslActionHelper.executeAction {__data:{}, __returnData:{}}, {}, 'most_played_cache', (err, resultSet) ->
		callback resultSet
		console.log 'finished cache most_played'