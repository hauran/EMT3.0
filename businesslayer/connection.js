(function() {
  var async, conn, fs, mustache, mysql, path, _;

  fs = require('fs');

  path = require('path');

  mustache = require('mustache');

  _ = require('underscore');

  async = require("async");

  mysql = require('mysql');

  conn = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: ''
  });

  conn.connect();

  exports.runScript = function(templateName, req, callback) {
    return fs.readFile("db/" + templateName + ".sql", "ascii", function(err, dbRun) {
      var dbScript;
      dbScript = mustache.render(dbRun, req.__data);
      console.log(dbScript);
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
