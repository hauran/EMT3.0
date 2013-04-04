(function() {
  var request;

  request = require('request');

  exports.serverRequest = function(req, url, jsonData, method, callback) {
    var requestObject;
    requestObject = {
      method: method,
      json: jsonData,
      timeout: 7000,
      headers: {
        cookie: 'rspy_l=' + req.cookies.rspy_l,
        Authorization: "Basic " + req.cookies.rspy_l
      }
    };
    return request(requestObject, function(error, response, body) {
      return callback(body.err, body.resultSet);
    });
  };

}).call(this);
