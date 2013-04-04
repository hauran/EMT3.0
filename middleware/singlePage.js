var _ = require('underscore');

exports = module.exports = function singlePage(options){
	var _indexPage = options.indexPage,
		acceptedExtensions = ['.ico','.js','.css','.eot','woff','ttf'];

	return function singlePage(req, res, next) {
		var staticFile = false;
		_.each(acceptedExtensions, function(element,index,list){
			if(req.url.indexOf(element)!=-1){
				staticFile = true;
			}
		});

		if (staticFile || 
			(req.headers['content-type'] && req.headers['content-type'].indexOf('application/json') > -1) ||
			(req.headers['accept'] && req.headers['accept'].indexOf('application/json') > -1) ||
			(req.headers['template'] && req.headers['template'].indexOf('true') > -1)
		) {
			next();
		}
		else{
			res.render (_indexPage);
		}
	}
};