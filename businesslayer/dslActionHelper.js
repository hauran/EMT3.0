(function() {
  var addResultsetToRequest, async, connection, executeActionSequence, executeChildSql, executeDB, executeNextAction, executePartialSql, fs, path, processParentChildQuery, tasks;

  fs = require('fs');

  path = require('path');

  async = require('async');

  connection = require('./connection');

  tasks = require('./tasks');

  exports.compileAllDSLActions = function(callback) {
    var actionDictionary, actionName, dslFiles, file, fileName, fullPath, fullPathFile, stats, _ref;
    actionDictionary = {};
    fullPath = './dsl/';
    dslFiles = fs.readdirSync(fullPath);
    for (file in dslFiles) {
      fileName = dslFiles[file];
      fullPathFile = path.join(fullPath, fileName);
      stats = fs.statSync(fullPathFile);
      if (stats.isDirectory() === false) {
        actionName = fileName.split('.')[0];
        if ((_ref = actionDictionary[actionName]) == null) {
          actionDictionary[actionName] = JSON.parse(fs.readFileSync(fullPathFile, 'utf8'));
        }
      }
    }
    return callback(actionDictionary);
  };

  exports.executeAction = function(req, res, actionName, callback) {
    var actionJson, counter, dbFilePath, htmlFilePath, returnResultSet;
    dbFilePath = "db/" + actionName + ".sql";
    htmlFilePath = "public/templates/" + actionName + ".html";
    if (GLOBAL.actionDictionary[actionName] != null) {
      actionJson = GLOBAL.actionDictionary[actionName];
      returnResultSet = {};
      counter = 0;
      return executeActionSequence(req, actionJson, counter, returnResultSet, callback);
    } else if (fs.existsSync(dbFilePath)) {
      return executeDB(req, actionName, callback, true);
    } else if (fs.existsSync(htmlFilePath)) {
      return callback(null, {});
    }
  };

  executeActionSequence = function(req, actionJson, counter, returnResultSet, callback) {
    var action, func;
    action = actionJson[counter];
    if (typeof action === 'string') {
      if (action.indexOf('.') > -1) {
        func = action.split('.');
        return global[func[0]][func[1]](req, function(err, returnValue) {
          return executeNextAction(req, actionJson, counter, returnValue, callback);
        });
      } else if (fs.existsSync("db/" + action + ".sql")) {
        return executeDB(req, action, function(err, returnValue) {
          return executeNextAction(req, actionJson, counter, returnValue, callback);
        });
      }
    } else if (typeof action === 'object') {
      if (action.sqlFileList) {
        return processParentChildQuery(action, req, function(err, resultSet) {
          if (err) {
            return handleError(req, err, callback);
          } else {
            return executeNextAction(req, actionJson, counter, resultSet, callback);
          }
        });
      } else {
        return executePartialSql(req, action, function(err, resultSet) {
          if (err) {
            return handleError(req, err, callback);
          } else {
            return executeNextAction(req, actionJson, counter, resultSet, callback);
          }
        });
      }
    } else {
      return callback(null, {});
    }
  };

  executeDB = function(req, action, callback) {
    var db;
    if (typeof action === 'object') {
      if ((action.view != null)) {
        req.__data.view = action.view;
      } else {
        req.__data.view = req.actionName;
      }
      db = action.db;
      if ((db != null) && fs.existsSync("db/" + db + ".sql")) {
        return connection.runScript(db, req, function(err, returnResultSet) {
          addResultsetToRequest(req, db, returnResultSet);
          return callback(err, returnResultSet);
        });
      } else {
        return callback(null, {});
      }
    } else if (typeof action === 'string') {
      return connection.runScript(action, req, function(err, returnResultSet) {
        addResultsetToRequest(req, action, returnResultSet);
        return callback(err, returnResultSet);
      });
    } else {
      return callback(null, {});
    }
  };

  executePartialSql = function(req, action, callback) {
    var actionName;
    actionName = action;
    if (typeof action === 'object') {
      actionName = action.sql;
      req.__data.select = action.select;
      req.__data.where = action.where;
      req.__data.data = action.data;
      if ((action.view != null)) {
        req.__data.view = action.view;
      }
    }
    return executeDB(req, actionName, callback);
  };

  processParentChildQuery = function(actionJson, req, callback) {
    var reqDataPropertyName, sqlFileList;
    sqlFileList = actionJson.sqlFileList;
    reqDataPropertyName = actionJson.propertyName;
    return executePartialSql(req, sqlFileList.parent, function(err, parentResultSet) {
      var childCounter, noData, parentCounter;
      if (err) {
        return callback(err, null);
      } else {
        if (parentResultSet.length > 0) {
          parentCounter = 0;
          childCounter = 0;
          return executeChildSql(req, parentResultSet, sqlFileList.children, parentCounter, childCounter, callback);
        } else {
          noData = [];
          addResultsetToRequest(req, reqDataPropertyName, noData);
          return callback(null, noData);
        }
      }
    });
  };

  executeChildSql = function(req, parentSet, children, parentCounter, childCounter, callback) {
    var child, joinColumnName, joinColumnValue, parent_row, propertyName;
    parent_row = parentSet[parentCounter];
    child = children[childCounter];
    propertyName = child.propertyName;
    joinColumnName = child.joinColumn;
    joinColumnValue = parent_row[joinColumnName];
    req.__data[joinColumnName] = joinColumnValue;
    return executePartialSql(req, child.query, function(err, childResultSet) {
      if (err) {
        callback(err, null);
      } else {
        parent_row[propertyName] = childResultSet;
      }
      childCounter++;
      if (childCounter === children.length) {
        childCounter = 0;
        parentCounter++;
      }
      if (parentCounter === parentSet.length) {
        return callback(null, parentSet);
      } else {
        return executeChildSql(req, parentSet, children, parentCounter, childCounter, callback);
      }
    });
  };

  executeNextAction = function(req, actionJson, counter, returnResultSet, callback) {
    var action, actionName, periodIndex;
    action = actionJson[counter];
    actionName = action;
    if (typeof action === 'object') {
      if (action.propertyName) {
        actionName = action.propertyName;
      } else if (action.db) {
        actionName = action.db;
      } else {
        actionName = req.actionName;
      }
    } else if (typeof action === 'string') {
      periodIndex = actionName.indexOf(".", 0);
      if (periodIndex > 0) {
        actionName = actionName.split('.')[1];
      }
    }
    addResultsetToRequest(req, actionName, returnResultSet);
    counter++;
    if (counter === actionJson.length) {
      return callback(null, req.__returnData);
    } else {
      return executeActionSequence(req, actionJson, counter, returnResultSet, callback);
    }
  };

  addResultsetToRequest = function(req, propertyName, resultSet) {
    if ((resultSet != null) && resultSet.length > 0) {
      req.__returnData[propertyName] = resultSet;
      req.__returnData[propertyName + '_count'] = resultSet.length;
      return req.__data[propertyName] = resultSet;
    }
  };

}).call(this);
