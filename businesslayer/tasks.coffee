fs = require('fs')
_ = require("underscore")
async = require("async")
nodemailer = require("nodemailer")
mustache = require('mustache')
request = require('request')
accounting = require('accounting')

_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
};

mixcard = fs.readFileSync "public/templates/partials/mixcard.html", "ascii"
mixcard_tracks_popover = fs.readFileSync "public/templates/partials/mixcard_tracks_popover.html", "ascii"
mixcard_collection = fs.readFileSync "public/templates/partials/mixcard_collection.html", "ascii"


exports.checkCache = (req, callback) ->
	if GLOBAL.cache[req.actionName]
		data = {}
		if (req.__data.row)
			start = parseInt(req.__data.row)
		else
			start = 0
		end = start + 5
		req.__returnData[GLOBAL.cache[req.actionName].propertyName] = GLOBAL.cache[req.actionName].cache.slice(start,end)
	callback null,{}

exports.mixcard_collection_partial = (req, callback) ->
	if(!req.__returnData.views?)
		req.__returnData.views = {}

	mixcard_collection_partial =  _.extend req.__returnData.views, {mixcard_collection:mixcard_collection,mixcard:mixcard}
	callback null,{}

exports.mixcardTracksPopoverPartial = (req,callback) ->
	if(!req.__returnData.partials?)
		req.__returnData.partials = {}

	req.__returnData.partials = _.extend req.__returnData.partials, {mixcard_tracks_popover:mixcard_tracks_popover}
	callback null,{}

exports.mixCardPartial =  (req, callback) ->
	if(!req.__returnData.partials?)
		req.__returnData.partials = {}

	req.__returnData.partials = _.extend req.__returnData.partials, {mixcard:mixcard_partial}
	callback null, {}

exports.formatNumbers = (req, callback) ->
	data = req.__returnData
	if(data.collection)
		_.each data.collection, (mix) ->
			_.each mix.stats, (stats, index) ->
				if stats[0] && stats[0].collected
					stats[0].collected = accounting.formatNumber(stats[0].collected)

					if parseInt(stats[0].plays) > 10000
						stats[0].plays = Math.floor(parseInt(stats[0].plays)/1000) + 'k'
					else
						stats[0].plays = accounting.formatNumber(stats[0].plays)
			if(mix.stats.length > 1)
				mix.stats.splice(0,2)
			mix.stats = _.flatten(mix.stats)
		delete req.__returnData.mix_stats
		delete req.__returnData.mix_stats_count
		delete req.__returnData.mix_tracks
		delete req.__returnData.mix_tracks_count
		delete req.__returnData.most_collected
		delete req.__returnData.most_collected_count
		delete req.__returnData.most_played
		delete req.__returnData.most_played_count

	if(data.stats)
		data.stats.splice(0,2)
		data.stats = _.flatten(data.stats)
		stats = data.stats[0]
		if stats.collected
			stats.collected = accounting.formatNumber(stats.collected)
			if parseInt(stats.plays) > 10000
				stats.plays = Math.floor(parseInt(stats.plays)/1000) + 'k'
			else
				stats.plays = accounting.formatNumber(stats.plays)
		delete req.__returnData.mix_stats
		delete req.__returnData.mix_tracks
		delete req.__returnData.mix_stats_count
		delete req.__returnData.mix_tracks_count
	callback null, {}

# http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&api_key= + GLOBAL.audioscrobbler_api_key + &format=json&limit=' + mixLength + '&artist=' + q;

exports.processPosts = (req, callback) ->
	email = req.__data.me.email
	_.each req.__data.posts, (ele) ->
		if email == ele.postedBy.email
			ele.mine = true
		
		if ele.illDoIt?
			dos = ele.illDoIt.length
			ele.illDoIt_count = dos
			theDoers = _.pluck(ele.illDoIt, 'email');
			if (_.indexOf(theDoers, email)!=-1 )
				ele.yesIllDoIt = true

		if ele.maybe?
			maybes = ele.maybe.length
			ele.maybe_count = maybes
			theMaybes = _.pluck(ele.maybe, 'email');
			if (_.indexOf(theMaybes, email)!=-1 )
				ele.maybeIllDoIt = true
	callback null, 1

exports.emailSent = (req, callback) ->
	if req.__data.title? and req.__data.title=='complete'
		req.__returnData.complete = true
	callback null, 1

exports.facebookSignIn = (req, callback) ->
	@facebookSignUp req, callback, true

exports.facebookSignUp = (req, callback, signIn) ->
	if signIn
		redirect = 'http://everyonesmixtape.com/facebookSignIn/'
	else
		redirect = 'http://everyonesmixtape.com/facebookSignUp/'
	code = url.parse(req.headers.referer, true).query.code
	getTokenURL = _.template("https://graph.facebook.com/oauth/access_token?client_id={{appId}}&redirect_uri={{redirect}}&client_secret={{appSecret}}&code={{code}}", {"code":code,"appId":GLOBAL.appId ,"appSecret":GLOBAL.appSecret,"redirect":redirect})
	request getTokenURL,  (error, response, body) ->
		token = body.split('=')[1]
		console.log token
		getFBInfo = _.template("https://graph.facebook.com/me?access_token={{token}}", {"token":token})
		request getFBInfo,  (error, response, body) ->
			me = JSON.parse(body);
			moreInfo = 'https://graph.facebook.com/' + me.id + '?access_token=' + token + '&fields=id,name,first_name,last_name,email,username,picture,likes,friends.fields(email,name,picture)'
			request moreInfo,  (error, response, body) ->
				console.log 'moreFBData', body
				moreFBData = JSON.parse(body)
				req.__data.FBData = moreFBData
				req.__data.auth = {}
				req.__data.auth.email = moreFBData.email

				Authentication.authenticate req, (err, results) ->
					if results.length == 1
						req.__data.me = results
						mongoDB.runScript 'updateFacebookData', req, (err, returnResultSet) ->
							callback null, returnResultSet
					else
						mongoDB.runScript 'facebookSignUp', req, (err, returnResultSet) ->
							callback null, returnResultSet

exports.sendEmail = (req, callback) ->
	reqData = req.__data
	mailOptions = {
	    from: reqData.name + '<' + reqData.email + '>',
	    to:'richardmai@gmail.com',
	    subject:'sent from AlizaPai.com - Contact',
	    text:reqData.body
	}
	smtpTransport.sendMail mailOptions, (error, response) ->
	    if(error)
	        console.log(error)
	    else
	        console.log("Message sent: " + response.message);

	callback null, 1