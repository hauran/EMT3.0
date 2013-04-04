# databaseUrl = process.env.OPENSHIFT_MONGODB_DB_URL || ""
# database = "resippy"
# collections = ["users","favors"]
# mongo = require("mongodb")
# BSON = mongo.BSONPure
# db = require("mongojs").connect(databaseUrl + database , collections)
fs = require('fs')
path = require('path')
mustache = require('mustache')
# timeago = require('timeago')
_ = require('underscore')
async = require("async")
mysql = require('mysql')


conn = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : ''
})

conn.connect()

exports.runScript = (templateName, req, callback) ->
	fs.readFile "db/" + templateName + ".sql", "ascii", (err, dbRun) ->
		dbScript = mustache.render(dbRun, req.__data)
		console.log(dbScript)
		conn.query "use EMT"
		conn.query dbScript, (err, rows, fields) ->
		  if (err) 
		  	throw err
		  # console.log rows
		  callback null, rows