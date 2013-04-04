(function() {
  var app, dslActionHelper, express, fs, http, ip, isNull, path, port, server, util, _;

  express = require('express');

  http = require('http');

  fs = require("fs");

  path = require("path");

  _ = require("underscore");

  util = require("util");

  app = express();

  server = http.createServer(app);

  dslActionHelper = require('./businesslayer/dslActionHelper');

  GLOBAL.actionDictionary = {};

  GLOBAL.appId = "447275615345245";

  GLOBAL.appSecret = "39ee3fe876d6f33d399ccdc1642fea3a";

  GLOBAL.audioscrobbler_api_key = "ab13e2a8580857bcd35728dd7f5e8c60";

  GLOBAL.rooms = {};

  dslActionHelper.compileAllDSLActions(function(actionDictionary) {
    return GLOBAL.actionDictionary = actionDictionary;
  });

  app.configure(function() {
    var requestValues, singlePage;
    requestValues = require('./middleware/requestValues');
    singlePage = require('./middleware/singlePage');
    app.engine("html", require("ejs").renderFile);
    app.set("view options", {
      layout: false
    });
    app.set("views", __dirname + "/public");
    app.set("view engine", "ejs");
    app.use(express.bodyParser());
    app.use(express.cookieParser());
    app.use(express["static"](__dirname + "/public"));
    app.use(express.methodOverride());
    app.use(singlePage({
      indexPage: "index.html"
    }));
    app.use(requestValues());
    return app.use(app.router);
  });

  ip = process.env.OPENSHIFT_NODEJS_IP || "127.0.0.1";

  port = process.env.OPENSHIFT_NODEJS_PORT || 8080;

  console.log("--------------------");

  console.log(ip, port);

  server.listen(port, ip);

  app.get('/:action/:title?/:id?', function(req, res, next) {
    var actionName, id, payload, queryStringJson;
    actionName = req.params.action;
    queryStringJson = qs.parse(url.parse(req.url).query);
    _.extend(req.__data, queryStringJson);
    payload = {};
    id = req.params.id;
    if ((id != null)) {
      req.__data = id;
    }
    if (req.params.title) {
      actionName = req.params.title;
    }
    req.actionName = actionName;
    return dslActionHelper.executeAction(req, res, actionName, function(err, resultSet) {
      var view;
      if (err) {
        return next(err);
      } else {
        payload.data = req.__returnData;
        if ((req.__data.params != null)) {
          payload.data.params = req.__data.params;
        }
        view = actionName;
        if (req.__data.view != null) {
          if (typeof req.__data.view === 'string') {
            view = req.__data.view;
          } else {
            if (payload.data.items != null) {
              if (payload.data.items.length > 1) {
                view = req.__data.view.listing;
              } else {
                view = req.__data.view.details;
              }
            } else {
              view = actionName;
            }
          }
        }
        return fs.readFile("public/templates/" + view + ".html", "ascii", function(err, htmlView) {
          return res.json({
            view: htmlView,
            payload: payload
          });
        });
      }
    });
  });

  app.post('/post/:name/:id?', function(req, res, next) {
    var actionName, id, payload;
    actionName = req.params.name;
    payload = {};
    id = req.params.id;
    if ((id != null)) {
      req.__data.id = id;
    }
    return dslActionHelper.executeAction(req, res, actionName, function(err, resultSet) {
      if (err) {
        return next(err);
      } else {
        payload.data = req.__returnData;
        return res.json({
          action: req.__data.nextAction,
          payload: payload
        }, 200);
      }
    });
  });

  String.prototype.replaceAll = function(replaceThis, withThis) {
    return this.replace(new RegExp(replaceThis, "g"), withThis);
  };

  String.prototype.trim = function() {
    return this.replace(/^\s\s*/, "").replace(/\s\s*$/, "");
  };

  isNull = function(obj) {
    if (obj === null || typeof obj === "undefined") {
      return true;
    } else {
      return false;
    }
  };

}).call(this);
