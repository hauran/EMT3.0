fs = require('fs')
path = require('path')
async = require('async')
connection = require ('./connection')
tasks = require('./tasks')
utils = require('./utils')


exports.compileAllDSLActions = (callback) ->
	actionDictionary = {}
	fullPath = './dsl/'
	dslFiles = fs.readdirSync(fullPath);
	for file of dslFiles
		fileName = dslFiles[file]
		fullPathFile = path.join fullPath, fileName
		stats = fs.statSync fullPathFile
		if stats.isDirectory() == false
			actionName = fileName.split('.')[0]
			actionDictionary[actionName]?= JSON.parse(fs.readFileSync(fullPathFile,'utf8'))
	callback actionDictionary

exports.executeAction = (req, res, actionName, callback) ->
	# console.log 'executeAction', actionName
	dbFilePath = "db/" + actionName + ".sql"
	htmlFilePath = "public/templates/" + actionName + ".html"
	
	if GLOBAL.actionDictionary[actionName]?
		# console.log 'dsl json file'
		actionJson = GLOBAL.actionDictionary[actionName]
		returnResultSet = {}
		counter = 0
		executeActionSequence req, actionJson, counter, returnResultSet, callback

	else if (fs.existsSync(dbFilePath))
		executeDB req, actionName, callback, true

	else if (fs.existsSync(htmlFilePath))
		callback null, {}

executeActionSequence = (req, actionJson, counter, returnResultSet, callback) ->
	action = actionJson[counter]
	# console.log 'executeActionSequence',  action

	if typeof action is 'string'  
		if action.indexOf('.') > -1
			func = action.split('.')
			global[func[0]][func[1]] req, (err, returnValue) ->
				executeNextAction req, actionJson, counter, returnValue, callback
		else if fs.existsSync("db/" + action + ".sql")
			executeDB req, action, (err, returnValue) ->
				executeNextAction req, actionJson, counter, returnValue, callback
	else if typeof action is 'object' 
		if action.sqlFileList # parent child query execution
			processParentChildQuery action, req, (err, resultSet) ->
				if (err)
					handleError req, err, callback
				else
					executeNextAction req, actionJson, counter, resultSet, callback
		else #select query with sub selects/joins/where
			executePartialSql req, action, (err, resultSet) ->
				if (err)
					handleError req, err, callback
				else
					executeNextAction req, actionJson, counter, resultSet, callback
	# else if fs.existsSync("dsl/" + req.actionName + ".json")
	# 	executeDB req, action, (err, returnValue) ->
	# 		executeNextAction req, actionJson, counter, returnValue, callback
	else
		callback null, {}


executeDB = (req, action, callback) ->
	# console.log action
	if typeof action is 'object'
		if(action.view?)
			req.__data.view = action.view
		else 
			req.__data.view = req.actionName
	
		db = action.db
		if (db? and fs.existsSync("db/" + db+ ".sql"))
			# console.log 'execute db', db
			connection.runScript db, req, (err, returnResultSet) ->
				addResultsetToRequest req, db, returnResultSet
				callback  err, returnResultSet
		else 
			callback null, {}

	else if typeof action is 'string'
		# console.log 'connection', action
		connection.runScript action, req, (err, returnResultSet) ->
			# console.log 'connection returnResultSet', returnResultSet
			addResultsetToRequest req, action, returnResultSet
			callback  err, returnResultSet
	else 
		callback null, {}


executePartialSql = (req, action, callback) ->
	actionName = action
	if typeof action is 'object'
		actionName = action.sql	
		req.__data.select = action.select
		req.__data.where = action.where
		req.__data.data = action.data
		if(action.view?)
			req.__data.view = action.view
	
	executeDB req, actionName, callback


processParentChildQuery = (actionJson, req, callback) ->
	sqlFileList = actionJson.sqlFileList
	reqDataPropertyName = actionJson.propertyName
	executePartialSql req, sqlFileList.parent, (err, parentResultSet) ->
		if (err)
			callback err, null
		else
			if parentResultSet.length > 0
				parentCounter = 0;
				childCounter = 0;
				executeChildSql req, parentResultSet, sqlFileList.children, parentCounter, childCounter, callback
			else
				noData = []
				addResultsetToRequest req, reqDataPropertyName, noData
				callback null, noData

executeChildSql = (req, parentSet, children, parentCounter, childCounter, callback) ->
	parent_row = parentSet[parentCounter]
	child = children[childCounter]

	propertyName = child.propertyName
	joinColumnName = child.joinColumn
	joinColumnValue = parent_row[joinColumnName] 
	req.__data[joinColumnName] = joinColumnValue

	executePartialSql req, child.query, (err, childResultSet) ->
		if (err)
			callback err, null
		else
			parent_row[propertyName] = childResultSet

		childCounter++
		if(childCounter == children.length)
			childCounter = 0
			parentCounter++

		if(parentCounter==parentSet.length)
			callback null, parentSet
		else
			executeChildSql req, parentSet, children, parentCounter, childCounter, callback

executeNextAction = (req, actionJson, counter, returnResultSet, callback) ->
	action = actionJson[counter]

	# console.log action, returnResultSet

	# console.log action
	# if typeof action is 'string'
	# console.log 'executeNextAction', action, returnResultSet
	actionName = action
	if typeof action is 'object'
		if action.propertyName
			actionName = action.propertyName
		else if action.db
			actionName = action.db
		else
			actionName = req.actionName
	else if typeof action is 'string' 
		periodIndex = actionName.indexOf ".", 0
		if periodIndex > 0
			actionName = actionName.split('.')[1]

	addResultsetToRequest req, actionName, returnResultSet
	counter++
	if counter == actionJson.length
		# console.log 'DOOOOONNNNEEEEE', req.__returnData
		callback  null, req.__returnData
	else
		executeActionSequence req, actionJson, counter, returnResultSet, callback

addResultsetToRequest = (req, propertyName, resultSet) ->
	# console.log 'addResultsetToRequest', propertyName, resultSet
	if resultSet? and resultSet.length > 0 
		req.__returnData[propertyName] = resultSet

		jsonResult = JSON.stringify(resultSet, utils.sanitizeSlashes);
		jsonResult = utils.escapeQuote(jsonResult);
		req.__returnData[propertyName + "_serialize"] = {
			SerializedData: jsonResult
		};
		req.__returnData[propertyName + '_count'] = resultSet.length
		req.__data[propertyName] = resultSet 





