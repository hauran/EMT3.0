mixcard = () ->
	@showPopover = -1
	@hidePopover = null
	@closePopover = () ->
		_this = @
		setTimeout ( ->
			console.log _this.hidePopover

			if _this.hidePopover
				$('.mixCard').popover('hide')
		), 500
	@

EMT.mixCard = new mixcard()

$(document).hoverIntent 
	over: -> 
		setTimeout () ->
			console.log('hide 1', false)
			EMT.mixCard.hidePopover = false
		,100
		_this = @
		if($(_this).siblings('.popover').length == 0)
			$('.mixCard').popover('hide')
			$(_this).popover('show')

		EMT.get '/mix/mixcard_tracks_popover/' + $(_this).data('id'), {}, (data) ->
			view = data.payload.data.partials.mixcard_tracks_popover
			popover = $(_this).attr('data-content', Mustache.render(view, data.payload)).data('popover')
			popover.setContent()
			popover.$tip.addClass(popover.options.placement)
			$('.popover-content ul li:nth-child(10)').addClass('hide-after')
			$('.popover').css('top',($(_this).offset().top + 25) + 'px')

			if $('.popover-content ul li:nth-child(11)')[0]
				$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter('li.hide-after')
	out: (event)->
		console.log('hide 1', true)
		EMT.mixCard.hidePopover = true
		EMT.mixCard.closePopover()
	selector: '.mixCard'


$(document).on 'mouseenter', '.popover', () -> 
	setTimeout ( ->
		console.log('hide 2', false)
		EMT.mixCard.hidePopover = false
	), 100

$(document).on 'mouseleave', '.popover', () -> 
	console.log('hide 2', true)
	EMT.mixCard.hidePopover = true
	EMT.mixCard.closePopover()






############# FOR MOBILE #################
# $(document).on 'click', '.mixCard', (event) ->
# 	event.stopPropagation()
# 	_this = @
# 	$('.mixCard').popover('hide')
# 	$(_this).popover('show')
# 	EMT.get '/mix/mixcard_tracks_popover/' + $(_this).data('id'), {}, (data) ->
# 		view = data.payload.data.partials.mixcard_tracks_popover
# 		popover = $(_this).attr('data-content', Mustache.render(view, data.payload)).data('popover')
# 		popover.setContent()
# 		popover.$tip.addClass(popover.options.placement)
# 		$('.popover-content ul li:nth-child(10)').addClass('hide-after')
# 		$('.popover').css('top',($(_this).offset().top + 25) + 'px')

# 		if $('.popover-content ul li:nth-child(11)')[0]
# 			$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter('li.hide-after')

	
$(document).on 'click', 'ul.mix-tracks li.more', (event) ->
	event.stopPropagation()
	$(@).remove();
	$('ul.mix-tracks li.hide-after').removeClass('hide-after');


