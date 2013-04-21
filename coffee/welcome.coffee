EMT.mostCollected = (init) ->
	if(init)
		page = 0
	else
		lastPage = false
		numberOfSlides = $('.most-collected .iosSlider').data().iosslider.numberOfSlides
		page = $('.most-collected .iosSlider').data().args.currentSlideNumber
		if(numberOfSlides != page)
			return
	
	row = page * 5
	if(row==50)
		return

	EMT.get '/most_collected', {'row':row}, (data) ->
		if (init)
			$('.most-collected .slider').empty()

		$('.most-collected .slider').append(Mustache.render(data.payload.data.views.mixcard_collection, data.payload, data.payload.data.views))
		$('.most-collected .mixCard').popover {
			content:'Loading...',
			html:true,
			placement:EMT.mixCard.placement
		}
		$('.most-collected').data({'page':++page})
		if (init)
			$('.most-collected .iosSlider').iosSlider {
				snapToChildren: true,
				desktopClickDrag: true,
				keyboardControls: false,
				onSlideStart: () ->
					EMT.slideTransition = true
					$('.mixCard').popover('hide').removeClass('hover')
				onSlideComplete: () ->
					EMT.slideTransition = false
				onSlideChange: () ->
					EMT.mostCollected()
			}
			EMT.mostCollected()
		else
			$('.most-collected .iosSlider').iosSlider('update');

EMT.mostPlayed = (init) ->
	if(init)
		page = 0
	else
		lastPage = false
		numberOfSlides = $('.most-played .iosSlider').data().iosslider.numberOfSlides
		page = $('.most-played .iosSlider').data().args.currentSlideNumber
		if(numberOfSlides != page)
			return
	
	row = page * 5
	if(row==50)
		return
		
	EMT.get '/most_played', {'row':row}, (data) ->
		if (init)
			$('.most-played .slider').empty()

		$('.most-played .slider').append(Mustache.render(data.payload.data.views.mixcard_collection, data.payload, data.payload.data.views))
		$('.most-played .mixCard').popover {
			content:'Loading...',
			html:true,
			placement:EMT.mixCard.placement
		}
		if (init)
			$('.most-played .iosSlider').iosSlider {
				snapToChildren: true,
				desktopClickDrag: true,
				keyboardControls: false
				onSlideStart: () ->
					EMT.slideTransition = true
					$('.mixCard').popover('hide').removeClass('hover')
				onSlideComplete: () ->
					EMT.slideTransition = false
				onSlideChange: () ->
					EMT.mostPlayed()
			}
			EMT.mostPlayed()
		else
			$('.most-played .iosSlider').iosSlider('update');

