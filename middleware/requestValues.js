_ = require('underscore')
tasks = require('../businesslayer/tasks')
ajax = require('../businesslayer/ajaxRequest')
Authentication = require('../businesslayer/authentication')
url = require('url')
qs = require('querystring')
timeago = require('timeago')

var noAuthReqPaths = [
					'/coming_soon',
					'/welcome',
					'/facebookSignUp/',
					'/facebookSignIn/',
					'/login',
					'/post/logon',
					'/post/register_account',
					'/join/signup',
					'/join/register',
					'/favicon.ico'
 				]

exports = module.exports = function requestValues() {
	var _getAuthorizedEmail = function (authCode) {
		if (authCode){
			authCode = authCode.replace("Basic", "").trim();
			if (authCode != 'undefined'){
				var isAuthToken = true;
				if (authCode.match(":isToken=1$") == null){
					authCode = new Buffer(authCode, 'base64').toString('utf-8');
					isAuthToken = false;
				}
				authCode = authCode.split(':');
				
				return { email: authCode[0], password: authCode[1], authFromToken: isAuthToken };
			}
		}
		return { email: '', password: '' };
	}

	return function requestValues(req, res, next) {
		var queryStringJson = qs.parse(url.parse(req.url).query);
		delete queryStringJson['_'];
		var queryString = qs.stringify(queryStringJson,'&','=');
		req.url = url.parse(req.url).pathname;		
		if (queryString.length > 0){
			req.url = req.url + '?' + queryString;	
		} 

		var authCode = req.headers["authorization"];
		req.__data = {};
		req.__returnData = {};
  		_.extend(req.__data, queryStringJson)
  		_.extend(req.__data, req.body)

  		if(_.indexOf(noAuthReqPaths, req.url) == -1) {
			req.__data.auth = _getAuthorizedEmail(authCode);
			if(!_.isUndefined(req.__data.auth) && req.__data.auth.email && req.__data.auth.email!=''){
				Authentication.authenticate(req, function(err, results){
					if(results && results.length==1){
						req.__returnData.me=results[0];
						req.__data.me=results[0];
						next();
					}
					else {
						res.send({}, 401);
					}
				});
			}
			else {
				res.send({}, 401);
			}
		}
		else {
			next();
		}
	}
};