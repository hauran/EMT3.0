EMT.mostPlayed = () ->
	EMT.get '/most_played', {}, (data) ->
		$('.most-played .slider').html(Mustache.render(data.payload.data.views.mixcard_collection, data.payload, data.payload.data.views))
		$('.most-played .mixCard').popover {
			content:'Loading...',
			html:true,
			placement:EMT.mixCard.placement
		}


EMT.mostCollected = () ->
	EMT.get '/most_collected', {}, (data) ->
		$('.most-collected .slider').html(Mustache.render(data.payload.data.views.mixcard_collection, data.payload, data.payload.data.views))

		$('.most-collected .mixCard').popover {
			content:'Loading...',
			html:true,
			placement:EMT.mixCard.placement
		}

EMT.slideRight = ($content, speed) ->
	curLeft = $content.position().left
	ww = $(window).width()
	cw = $content.width()
	if(curLeft > -1*(cw-ww+10))
		$content.css('left', (curLeft-speed) + 'px')
	else
		clearInterval(EMT.slide)

EMT.slideLeft = ($content, speed) ->
	curLeft = $content.position().left
	if(curLeft < 0)
		$content.css('left', (curLeft+speed) + 'px')
	else 
		clearInterval(EMT.slide)

EMT.expandLoginSignup = (e, page) ->
	e.stopPropagation();
	e.preventDefault();
	$cont = $('.sign-up-in')
	$cont.removeClass('signUp register login')
	$cont.addClass('expand').addClass(page)
	$cont.find('.btn.action').hide()
	$cont.find('.form').empty()

EMT.defaultLoginSignup = () ->
	$cont = $('.sign-up-in')
	$cont.removeClass('expand signUp register login')
	$cont.find('.btn.action').show()
	$cont.find('.form').empty()

if !EMT.isTouch
	$(document).on 'mouseenter', '.direction.right', () ->
		$('.mixCard').popover('hide').removeClass('hover')
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideRight $content, 4
		), 10

	$(document).on 'mouseenter', '.direction.left', () ->
		$('.mixCard').popover('hide').removeClass('hover')
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideLeft $content, 4
		), 10

	$(document).on 'mousedown', '.direction.right', () ->
		clearInterval(EMT.slide)
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideRight $content, 8
		), 10

	$(document).on 'mousedown', '.direction.left', () ->
		clearInterval(EMT.slide)
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideLeft $content, 8
		), 10

	$(document).on 'mouseup', '.direction', () ->
		clearInterval(EMT.slide)
		$(this).trigger('mouseenter') 

	$(document).on 'mouseleave', '.direction', () ->
		clearInterval(EMT.slide)


	$(document).on 'click', '.joinBtn', (e) ->
		EMT.expandLoginSignup(e, 'signUp')
		EMT.pageRouter.navigate 'signUp', {trigger: false, replace:false}
		EMT.renderPartial {}, 'signUp.html', (html) ->
			console.log(html)
			$('.form').html(html)


	$(document).on 'click', '.loginBtn', (e) ->
		EMT.expandLoginSignup(e, 'login')
		EMT.pageRouter.navigate 'login', {trigger: false, replace:false}
		EMT.renderPartial {}, 'login.html', (html) ->
			$('.form').html(html)

	$(document).on 'click', '.registerBtn', (e) ->
		EMT.expandLoginSignup(e, 'register')
		EMT.pageRouter.navigate 'register', {trigger: false, replace:false}
		EMT.renderPartial {}, 'register.html', (html) ->
			$('.form').html(html)

	$(document).on 'click', '.sign-up-in .close', (e) ->
		EMT.defaultLoginSignup()
		EMT.pageRouter.navigate '/welcome', {trigger: false, replace:false}
else
	hammertime.on 'touch', '.direction.right', () ->
		clearInterval(EMT.slide)
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideRight $content, 16
		), 10

	hammertime.on 'touch', '.direction.left', () ->
		clearInterval(EMT.slide)
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideLeft $content, 16
		), 10

	hammertime.on 'release', '.direction', () ->
		clearInterval(EMT.slide)
		$(this).trigger('mouseenter') 

