(function() {
  var dslActionHelper;

  dslActionHelper = require('./dslActionHelper');

  exports.most_collected = function(callback) {
    console.log('start cache most_collected', new Date());
    return dslActionHelper.executeAction({
      __data: {},
      __returnData: {}
    }, {}, 'most_collected_cache', function(err, resultSet) {
      callback(resultSet);
      return console.log('finished cache most_collected', new Date());
    });
  };

  exports.most_played = function(callback) {
    console.log('start cache most_played', new Date());
    return dslActionHelper.executeAction({
      __data: {},
      __returnData: {}
    }, {}, 'most_played_cache', function(err, resultSet) {
      callback(resultSet);
      return console.log('finished cache most_played', new Date());
    });
  };

}).call(this);
