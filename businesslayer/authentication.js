(function() {
  var connection, fs, path, tasks;

  fs = require('fs');

  path = require('path');

  connection = require('./connection');

  tasks = require('./tasks');

  exports.authenticate = function(req, callback) {
    return connection.runScript('authenticate', req, function(err, returnResultSet) {
      return callback(err, returnResultSet);
    });
  };

}).call(this);
