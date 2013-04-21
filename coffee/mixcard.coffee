mixcard = () ->
	@showPopover = -1
	@hidePopover = null
	@closePopover = () ->
		_this = @
		setTimeout ( ->
			if _this.hidePopover
				$('.mixCard').popover('hide').removeClass('hover')
		), 500
	@placement = () ->
		$mixCard = $('.mixCard.hover')
		rightPosOfPopOver = $mixCard.offset().left + $mixCard.width() + 250;
		if(rightPosOfPopOver > $(window).width())
				return 'left'
		return 'right'

	@
EMT.mixCard = new mixcard()


$(document).hoverIntent 
	over: -> 
		if(!EMT.slideTransition)
			setTimeout () ->
				EMT.mixCard.hidePopover = false
			,100
			_this = @
			if($(_this).siblings('.popover').length == 0)
				$('.mixCard').popover('hide').removeClass('hover')

				$(_this).addClass('hover')
				$(_this).popover('show')
				$('.popover').css('top','0px')

			EMT.get '/mixcard_tracks_popover/' + $(_this).data('id'), {}, (data) ->
				view = data.payload.data.partials.mixcard_tracks_popover
				popover = $(_this).attr('data-content', Mustache.render(view, data.payload)).data('popover')
				popover.setContent()

				popover.$tip.addClass(popover.options.placement)
				$('.popover-content ul li:nth-child(10)').addClass('hide-after')

				if $('.popover-content ul li:nth-child(11)')[0]
					$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter('li.hide-after')

				$('.popover').insertAfter($(_this).closest('.iosSlider'))
	out: (event)->
		EMT.mixCard.hidePopover = true
		EMT.mixCard.closePopover()
	selector: '.mixCard'


$(document).on 'mouseenter', '.popover', () -> 
	setTimeout ( ->
		EMT.mixCard.hidePopover = false
	), 100

$(document).on 'mouseleave', '.popover', () -> 
	EMT.mixCard.hidePopover = true
	EMT.mixCard.closePopover()

############# FOR MOBILE - CLICK #################
# $(document).on 'click', '.mixCard', (event) ->
# 	event.stopPropagation()
# 	_this = @
# 	$('.mixCard').popover('hide').removeClass('hover')

# 	$(_this).addClass('hover')
# 	$(_this).popover('show')
# 	$('.popover').css('top','0px')

# 	EMT.get '/mixcard_tracks_popover/' + $(_this).data('id'), {}, (data) ->
# 		view = data.payload.data.partials.mixcard_tracks_popover
# 		popover = $(_this).attr('data-content', Mustache.render(view, data.payload)).data('popover')
# 		popover.setContent()
# 		popover.$tip.addClass(popover.options.placement)
# 		$('.popover-content ul li:nth-child(10)').addClass('hide-after')

# 		if $('.popover-content ul li:nth-child(11)')[0]
# 			$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter('li.hide-after')
# 		$('.popover').insertAfter($(_this).closest('.iosSlider'))

$(document).on 'click', '.mixCard', (event) ->
	if(!EMT.slideTransition)
		id = $(this).data('id')
		EMT.mixId = id
		EMT.pageRouter.navigate('/mix/'+id + '/1', {trigger:true, replace:true});

$(document).on 'click', '.popover ul.mix-tracks li:not(.more)', (event) ->
	id = $(this).closest('.popover').siblings('.mixCard').data('id')
	EMT.mixId = id
	track = $(this).index()+1
	EMT.pageRouter.navigate('/mix/' + id + '/' + track, {trigger:true, replace:true});

$(document).on 'click', '.popover ul.mix-tracks li.more', (event) ->
	event.stopPropagation()
	$(@).remove();
	$('ul.mix-tracks li.hide-after').removeClass('hide-after');


