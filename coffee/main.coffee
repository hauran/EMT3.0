EMT = {}
EMT.HOME_PAGE = 'home'
EMT.PHONE_GAP = false
EMT.LOGIN_COOKIE = 'emt_l'
EMT.partials = {}
EMT.meId
EMT.meEmail
EMT.controls
EMT.YT
EMT.YTPlayer
EMT.YTupdateInterval
EMT.SC
EMT.SCID = '002ef906c036a78c4cfad7c6c08a84dd'
EMT.mixId
EMT.trackList 
EMT.currentTrack
EMT.mixCard
EMT.slideTransition

EMT.BaseView = Backbone.View.extend({})
EMT.BaseModel = Backbone.Model.extend({})
EMT.PageModel = EMT.BaseModel.extend({})

EMT.Partials = {}

EMT.PageView = EMT.BaseView.extend {
	el: $("body")
	,events: {
		"click .nav-link": "linkClick",
		"click .logout": "logout",
		"submit form.post-form": "postForm"
	}
	,linkClick: (e) ->
		e.preventDefault()
		$target = $(e.target)
		action = $target.data('href')

		if !action? #try getting data-href from parent
			action = $target.closest('.nav-link').data('href')
		if !action? #get href
			action = e.target.pathname or e.currentTarget.pathname
			if e.target.search
				action = action + e.target.search;

		if _.isUndefined(action) 
			action = '/'
			
		EMT.pageRouter.navigate action, {trigger: true, replace:false}
	
	,postForm:(e) ->
		e.preventDefault();
		postAction = $(e.target).attr('action');
		jsonData = $(e.target).serializeJSON();
		EMT.post postAction, jsonData, (json) ->
			EMT.pageRouter.navigate json.action, {trigger:true, replace:true}
	,logout:(e) ->
		e.preventDefault()
		$.removeCookie EMT.LOGIN_COOKIE, { path: '/' }
		location = EMT.phoneGapUrl ('welcome')
		window.location.href = location
}

EMT.PageRouter = Backbone.Router.extend {
	routes: {
		'*action' : 'fetchContent'
	},
	templateName: '',
	routerPageView:{},
	initialize: () ->
		_pageModel = new EMT.PageModel()
		this.routerPageView = new EMT.PageView({model:_pageModel})
	, 
	fetchContent: (action) ->
		_this = this;
		if (action is '' || action is '/') 
			action = EMT.HOME_PAGE
		else 
			highlight = action
			if action.indexOf('/') > 0
				highlight = action.split('/')[0]
			action = '/' + action

		if(EMT.PHONE_GAP)
			if(action.indexOf('www') != -1) 
		      action = action.substr(action.indexOf('www')+4)
		      if(action == 'index.html')
		        action = "/home"
		
		EMT.get action, null, (json) ->
			_this._pageViewSetModel(json)
	,
	_pageViewSetModel: (json) ->
		$('#_EMT').html(Mustache.render(json.view, json.payload,json.payload.data.partials))
		$(window).scrollTop(0)
}

(($) ->
  $.fn.serializeJSON = ->
    json = {}
    jQuery.map $(this).serializeArray(), (n, i) ->
      json[n["name"]] = n["value"]

    json
) jQuery


hammertime = $(document).hammer()

$(document).ready  ->
	EMT.pageRouter = new EMT.PageRouter()
	Backbone.history.start {pushState: true}

	$(document).click () ->
		$('.mixCard').popover('hide')

	