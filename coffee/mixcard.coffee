mixcard = () ->
	@showPopover = -1
	@hidePopover = null
	@closePopover = () ->
		_this = @
		$('body').removeClass('stop-scrolling')
		setTimeout ( ->
			if _this.hidePopover
				$('.mixCard').popover('hide').removeClass('hover')
		), 500
	@placement = () ->
		$mixCard = $('.mixCard.hover')
		if($mixCard.offset())
			rightPosOfPopOver = $mixCard.offset().left + $mixCard.width() + 250;
			if(rightPosOfPopOver > $(window).width())
				return 'left'
			return 'right'
		else
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
				top = $(_this).offset().top
				

			EMT.get '/mixcard_tracks_popover/' + $(_this).data('id'), {}, (data) ->
				view = data.payload.data.partials.mixcard_tracks_popover
				$(_this).popover('show')
				sliderLeft = $(_this).closest('.content').position().left
				left = $('.popover').position().left
				$('.popover').css({'top':(top - 50) + 'px', 'left':(sliderLeft + left + 10) + 'px'})

				popover = $(_this).attr('data-content', Mustache.render(view, data.payload)).data('popover')
				popover.setContent()

				popover.$tip.addClass(popover.options.placement)
				$('.popover-content ul li:nth-child(10)').addClass('hide-after')

				if $('.popover-content ul li:nth-child(11)')[0]
					$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter('li.hide-after')

				$('.popover').insertAfter($(_this).closest('.collection'))
	selector: '.mixCard'
	interval: 500

$(document).on 'mouseleave', '.mixCard', () -> 
	EMT.mixCard.hidePopover = true
	EMT.mixCard.closePopover()

$(document).on 'mouseenter', '.popover', () -> 
	setTimeout ( ->
		EMT.mixCard.hidePopover = false
		$('body').addClass('stop-scrolling')
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
# 	top = $(_this).offset().top

# 	sliderLeft = $(_this).closest('.content').position().left
# 	left = $('.popover').position().left
# 	$('.popover').css({'top':(top - 50) + 'px', 'left':(sliderLeft + left + 10) + 'px'})

# 	EMT.get '/mixcard_tracks_popover/' + $(_this).data('id'), {}, (data) ->
# 		view = data.payload.data.partials.mixcard_tracks_popover
# 		popover = $(_this).attr('data-content', Mustache.render(view, data.payload)).data('popover')
# 		popover.setContent()
# 		popover.$tip.addClass(popover.options.placement)
# 		$('.popover-content ul li:nth-child(10)').addClass('hide-after')

# 		if $('.popover-content ul li:nth-child(11)')[0]
# 			$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter('li.hide-after')
# 		$('.popover').insertAfter($(_this).closest('.collection'))

$(document).on 'click', '.mixCard', (event) ->
	if(!EMT.slideTransition)
		id = $(this).data('id')
		EMT.mixId = id
		EMT.mixCard.closePopover()
		EMT.pageRouter.navigate('/mix/' + id + '/1', {trigger:true, replace:true});

$(document).on 'click', '.popover ul.mix-tracks li:not(.more)', (event) ->
	id = $('.mixCard.hover').data('id')
	EMT.mixId = id
	track = $(this).index()+1
	EMT.pageRouter.navigate('/mix/' + id + '/' + track, {trigger:true, replace:true});

$(document).on 'click', '.popover ul.mix-tracks li.more', (event) ->
	event.stopPropagation()
	$(@).remove();
	$('ul.mix-tracks li.hide-after').removeClass('hide-after');


