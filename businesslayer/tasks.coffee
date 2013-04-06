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

mix_partial = fs.readFileSync "public/templates/partials/mix.html", "ascii"

exports.mixPartial =  (req, callback) ->
	if(!req.__returnData.partials?)
		req.__returnData.partials = {}

	req.__returnData.partials = _.extend req.__returnData.partials, {mix:mix_partial}
	callback null, {}

exports.formatNumbers = (req, callback) ->
	data = req.__returnData
	if data.most_played
		_.each data.most_played, (mix) ->
			_.each mix.stats, (stats, index) ->
				if stats[0].collected
					stats[0].collected = accounting.formatNumber(stats[0].collected)
					stats[0].plays = accounting.formatNumber(stats[0].plays)
			mix.stats.splice(0,2)
			mix.stats = _.flatten(mix.stats)

		_.each data.most_collected, (mix) ->
			_.each mix.stats, (stats, index) ->
				if stats[0].collected
					stats[0].collected = accounting.formatNumber(stats[0].collected)
					stats[0].plays = accounting.formatNumber(stats[0].plays)
			mix.stats.splice(0,2)
			mix.stats = _.flatten(mix.stats)

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