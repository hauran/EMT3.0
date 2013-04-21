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

host = process.env.OPENSHIFT_MYSQL_DB_HOST || 'localhost'
port =  process.env.OPENSHIFT_MYSQL_DB_PORT || null
user = process.env.OPENSHIFT_MYSQL_DB_USERNAME  || 'root'
password = process.env.OPENSHIFT_MYSQL_DB_PASSWORD || ''
connectionObj = {
  host     : host,
  user     : user,
  password : password,
  multipleStatements:true
}

if (process.env.OPENSHIFT_MYSQL_DB_HOST)
	connectionObj.port = port

conn = mysql.createConnection(connectionObj)
# conn = mysql.createConnection('mysql://' + user + ':' + password + '@' + host + '/EMT?flags=-TRANSACTIONS,-FOUND_ROWS,-MULTI_RESULTS,-PS_MULTI_RESULTS,-NO_SCHEMA,MULTI_STATEMENTS')
conn.connect()

exports.runScript = (templateName, req, callback) ->
	fs.readFile "db/" + templateName + ".sql", "ascii", (err, dbRun) ->
		# console.log(req.__data)
		dbScript = mustache.render(dbRun, req.__data)
		# console.log dbScript
		conn.query "use EMT"
		conn.query dbScript, (err, rows, fields) ->
		  if (err) 
		  	throw err
		  # console.log rows
		  callback null, rows