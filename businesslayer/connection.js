(function() {
  var async, conn, connectionObj, fs, host, mustache, mysql, password, path, port, user, _;

  fs = require('fs');

  path = require('path');

  mustache = require('mustache');

  _ = require('underscore');

  async = require("async");

  mysql = require('mysql');

  host = process.env.OPENSHIFT_MYSQL_DB_HOST || 'localhost';

  port = process.env.OPENSHIFT_MYSQL_DB_PORT || null;

  user = process.env.OPENSHIFT_MYSQL_DB_USERNAME || 'root';

  password = process.env.OPENSHIFT_MYSQL_DB_PASSWORD || '';

  connectionObj = {
    host: host,
    user: user,
    password: password
  };

  if (process.env.OPENSHIFT_MYSQL_DB_HOST) {
    connectionObj.port = port;
  }

  conn = mysql.createConnection(connectionObj);

  conn.connect();

  exports.runScript = function(templateName, req, callback) {
    return fs.readFile("db/" + templateName + ".sql", "ascii", function(err, dbRun) {
      var dbScript;
      dbScript = mustache.render(dbRun, req.__data);
      conn.query("use EMT");
      return conn.query(dbScript, function(err, rows, fields) {
        if (err) {
          throw err;
        }
        return callback(null, rows);
      });
    });
  };

}).call(this);
