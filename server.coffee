express = require('express')
http = require('http')
fs = require("fs")
path = require("path")
_ = require("underscore")
util = require("util")

app = express()
server = http.createServer(app)
# io = require('socket.io').listen(server, { log: false })

dslActionHelper = require('./businesslayer/dslActionHelper')
cache = require('./businesslayer/cache')

GLOBAL.actionDictionary = {}
GLOBAL.cache = {}
GLOBAL.appId = "447275615345245"
GLOBAL.appSecret = "39ee3fe876d6f33d399ccdc1642fea3a"
GLOBAL.audioscrobbler_api_key = "ab13e2a8580857bcd35728dd7f5e8c60"
GLOBAL.rooms = {};
dslActionHelper.compileAllDSLActions (actionDictionary) ->
  GLOBAL.actionDictionary = actionDictionary

cache.most_collected (cache) ->
  GLOBAL.cache.most_collected = {propertyName:'collection', cache: cache.collection}

cache.most_played (cache) ->
  GLOBAL.cache.most_played = {propertyName:'collection', cache: cache.collection}

app.configure ->
  requestValues = require './middleware/requestValues'
  singlePage = require './middleware/singlePage'
  app.engine "html", require("ejs").renderFile
  app.set "view options",
    layout: false

  app.set "views", __dirname + "/public"
  app.set "view engine", "ejs"
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.static(__dirname + "/public")
  app.use express.methodOverride()
  app.use singlePage(indexPage: "index.html")
  app.use requestValues()
  app.use app.router

ip = process.env.OPENSHIFT_NODEJS_IP or "127.0.0.1"
port = process.env.OPENSHIFT_NODEJS_PORT or 8080
console.log "--------------------"
console.log ip, port

server.listen port, ip



app.get '/:action/:id?/:track?', (req, res, next) ->
  actionName = req.params.action
  queryStringJson = qs.parse(url.parse(req.url).query)
  _.extend(req.__data, queryStringJson)
  payload = {}
  id = req.params.id
  if (id?)
    req.__data.id = id

  # if (req.params.title)
  #   actionName = req.params.title

  req.actionName = actionName

  dslActionHelper.executeAction req, res, actionName, (err, resultSet) ->
    if err
        next(err)
      else
        payload.data = req.__returnData
        if (req.__data.params?)
          payload.data.params = req.__data.params
        view = actionName
        if req.__data.view?
          if typeof req.__data.view is 'string'
            view = req.__data.view
          else 
            if payload.data.items?
              if payload.data.items.length > 1
                view = req.__data.view.listing
              else
                view = req.__data.view.details
            else
              view = actionName
        fs.readFile "public/templates/" + view + ".html", "ascii", (err, htmlView) ->
            res.json({view: htmlView, payload: payload})

app.post '/post/:name/:id?', (req, res, next) ->
  actionName = req.params.name
  payload = {}

  id = req.params.id
  if (id?)
    req.__data.id = id

  dslActionHelper.executeAction req, res, actionName, (err, resultSet) -> 
    if err
      next(err)
    else
      # console.log 'post done', req.__returnData
      payload.data = req.__returnData
      res.json({action: req.__data.nextAction, payload: payload}, 200)  

# io.sockets.on 'connection', (socket) ->
#   socket.on 'disconnect', () ->
#     console.log('disconnected', this.email)
#     delete GLOBAL.rooms[this.email]

#   socket.on 'signedIn', (email) ->
#     this.email = email
#     console.log email, ' has signed in'
#     GLOBAL.rooms[email] = this;  
#     socket.join email      

String::replaceAll = (replaceThis, withThis) ->
  @replace new RegExp(replaceThis, "g"), withThis

String::trim = ->
  @replace(/^\s\s*/, "").replace /\s\s*$/, ""

isNull = (obj) ->
  if obj is null or typeof obj is "undefined"
    true
  else
    false

