request = require('request')

exports.serverRequest = (req, url, jsonData, method, callback) ->
	# requestUrl = process.env.WEBSITES_CMP + 'nodeApi/' + url
	requestObject = {
		# uri: requestUrl,
		method: method,
		json: jsonData,
		timeout: 7000,
		headers :{
			cookie:'rspy_l=' + req.cookies.rspy_l,
			Authorization:"Basic " + req.cookies.rspy_l
		}
	}
	
	request requestObject, (error, response, body) ->
		callback body.err, body.resultSet		