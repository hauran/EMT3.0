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
else
	hammertime.on 'touch', '.direction.right', () ->
		clearInterval(EMT.slide)
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideRight $content, 8
		), 10

	hammertime.on 'touch', '.direction.left', () ->
		clearInterval(EMT.slide)
		$content = $(this).siblings('.content')
		EMT.slide = setInterval (->
			EMT.slideLeft $content, 8
		), 10

	hammertime.on 'relase', '.direction', () ->
		clearInterval(EMT.slide)
		$(this).trigger('mouseenter') 

