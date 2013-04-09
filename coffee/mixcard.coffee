$(document).on 'click', '.mixCard', (event) ->
	event.stopPropagation()
	_this = @
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

	
$(document).on 'click', 'ul.mix-tracks li.more', (event) ->
	event.stopPropagation()
	$(@).remove();
	$('ul.mix-tracks li.hide-after').removeClass('hide-after');