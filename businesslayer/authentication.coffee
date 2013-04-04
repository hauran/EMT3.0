fs = require('fs')
path = require('path')
connection = require ('./connection')
tasks = require('./tasks')

exports.authenticate = (req, callback) ->
	connection.runScript 'authenticate', req, (err, returnResultSet) ->
		callback  err, returnResultSet
