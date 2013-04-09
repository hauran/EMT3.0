(function() {
  var accounting, async, fs, mixcard, mixcard_collection, mixcard_tracks_popover, mustache, nodemailer, request, _;

  fs = require('fs');

  _ = require("underscore");

  async = require("async");

  nodemailer = require("nodemailer");

  mustache = require('mustache');

  request = require('request');

  accounting = require('accounting');

  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g
  };

  mixcard = fs.readFileSync("public/templates/partials/mixcard.html", "ascii");

  mixcard_tracks_popover = fs.readFileSync("public/templates/partials/mixcard_tracks_popover.html", "ascii");

  mixcard_collection = fs.readFileSync("public/templates/partials/mixcard_collection.html", "ascii");

  exports.mixcard_collection_partial = function(req, callback) {
    var mixcard_collection_partial;
    if (!(req.__returnData.views != null)) {
      req.__returnData.views = {};
    }
    mixcard_collection_partial = _.extend(req.__returnData.views, {
      mixcard_collection: mixcard_collection,
      mixcard: mixcard
    });
    return callback(null, {});
  };

  exports.mixcardTracksPopoverPartial = function(req, callback) {
    if (!(req.__returnData.partials != null)) {
      req.__returnData.partials = {};
    }
    req.__returnData.partials = _.extend(req.__returnData.partials, {
      mixcard_tracks_popover: mixcard_tracks_popover
    });
    return callback(null, {});
  };

  exports.mixCardPartial = function(req, callback) {
    if (!(req.__returnData.partials != null)) {
      req.__returnData.partials = {};
    }
    req.__returnData.partials = _.extend(req.__returnData.partials, {
      mixcard: mixcard_partial
    });
    return callback(null, {});
  };

  exports.formatNumbers = function(req, callback) {
    var data;
    data = req.__returnData;
    _.each(data.collection, function(mix) {
      _.each(mix.stats, function(stats, index) {
        if (stats[0].collected) {
          stats[0].collected = accounting.formatNumber(stats[0].collected);
          if (parseInt(stats[0].plays) > 10000) {
            return stats[0].plays = Math.floor(parseInt(stats[0].plays) / 1000) + 'k';
          } else {
            return stats[0].plays = accounting.formatNumber(stats[0].plays);
          }
        }
      });
      mix.stats.splice(0, 2);
      return mix.stats = _.flatten(mix.stats);
    });
    return callback(null, {});
  };

  exports.processPosts = function(req, callback) {
    var email;
    email = req.__data.me.email;
    _.each(req.__data.posts, function(ele) {
      var dos, maybes, theDoers, theMaybes;
      if (email === ele.postedBy.email) {
        ele.mine = true;
      }
      if (ele.illDoIt != null) {
        dos = ele.illDoIt.length;
        ele.illDoIt_count = dos;
        theDoers = _.pluck(ele.illDoIt, 'email');
        if (_.indexOf(theDoers, email) !== -1) {
          ele.yesIllDoIt = true;
        }
      }
      if (ele.maybe != null) {
        maybes = ele.maybe.length;
        ele.maybe_count = maybes;
        theMaybes = _.pluck(ele.maybe, 'email');
        if (_.indexOf(theMaybes, email) !== -1) {
          return ele.maybeIllDoIt = true;
        }
      }
    });
    return callback(null, 1);
  };

  exports.emailSent = function(req, callback) {
    if ((req.__data.title != null) && req.__data.title === 'complete') {
      req.__returnData.complete = true;
    }
    return callback(null, 1);
  };

  exports.facebookSignIn = function(req, callback) {
    return this.facebookSignUp(req, callback, true);
  };

  exports.facebookSignUp = function(req, callback, signIn) {
    var code, getTokenURL, redirect;
    if (signIn) {
      redirect = 'http://everyonesmixtape.com/facebookSignIn/';
    } else {
      redirect = 'http://everyonesmixtape.com/facebookSignUp/';
    }
    code = url.parse(req.headers.referer, true).query.code;
    getTokenURL = _.template("https://graph.facebook.com/oauth/access_token?client_id={{appId}}&redirect_uri={{redirect}}&client_secret={{appSecret}}&code={{code}}", {
      "code": code,
      "appId": GLOBAL.appId,
      "appSecret": GLOBAL.appSecret,
      "redirect": redirect
    });
    return request(getTokenURL, function(error, response, body) {
      var getFBInfo, token;
      token = body.split('=')[1];
      console.log(token);
      getFBInfo = _.template("https://graph.facebook.com/me?access_token={{token}}", {
        "token": token
      });
      return request(getFBInfo, function(error, response, body) {
        var me, moreInfo;
        me = JSON.parse(body);
        moreInfo = 'https://graph.facebook.com/' + me.id + '?access_token=' + token + '&fields=id,name,first_name,last_name,email,username,picture,likes,friends.fields(email,name,picture)';
        return request(moreInfo, function(error, response, body) {
          var moreFBData;
          console.log('moreFBData', body);
          moreFBData = JSON.parse(body);
          req.__data.FBData = moreFBData;
          req.__data.auth = {};
          req.__data.auth.email = moreFBData.email;
          return Authentication.authenticate(req, function(err, results) {
            if (results.length === 1) {
              req.__data.me = results;
              return mongoDB.runScript('updateFacebookData', req, function(err, returnResultSet) {
                return callback(null, returnResultSet);
              });
            } else {
              return mongoDB.runScript('facebookSignUp', req, function(err, returnResultSet) {
                return callback(null, returnResultSet);
              });
            }
          });
        });
      });
    });
  };

  exports.sendEmail = function(req, callback) {
    var mailOptions, reqData;
    reqData = req.__data;
    mailOptions = {
      from: reqData.name + '<' + reqData.email + '>',
      to: 'richardmai@gmail.com',
      subject: 'sent from AlizaPai.com - Contact',
      text: reqData.body
    };
    smtpTransport.sendMail(mailOptions, function(error, response) {
      if (error) {
        return console.log(error);
      } else {
        return console.log("Message sent: " + response.message);
      }
    });
    return callback(null, 1);
  };

}).call(this);
