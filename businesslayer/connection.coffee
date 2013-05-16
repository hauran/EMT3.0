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

host = process.env.RDS_HOSTNAME or process.env.OPENSHIFT_MYSQL_DB_HOST or 'localhost'
port =  process.env.RDS_PORT or process.env.OPENSHIFT_MYSQL_DB_PORT or null
user = process.env.RDS_USERNAME or process.env.OPENSHIFT_MYSQL_DB_USERNAME  or 'root'
password =  process.env.RDS_PASSWORD or process.env.OPENSHIFT_MYSQL_DB_PASSWORD or ''
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