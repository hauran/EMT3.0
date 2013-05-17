$(document).on 'click', '#mix_stage ul.mix-tracks li', (event) ->
	EMT.currentTrack = $(this).index()
	EMT.controls.nextSong()
	EMT.highlightTrackPlaying()
	# id = $(this).closest('.popover').siblings('.mixCard').data('id')
	# EMT.mixId = id
	# track = $(this).index()+1
	# EMT.pageRouter.navigate('/mix/' + id + '/' + track, {trigger:true, replace:true});

$(document).on 'click', '#mix_stage #controls .next', (event) ->
	EMT.controls.nextSong()
	EMT.highlightTrackPlaying()

$(document).on 'click', '#mix_stage #controls .play-pause', (event) ->
	playing = EMT.controls.toggle()
	if playing
		$(this).find('i').removeClass('icon-play').addClass('icon-pause')
	else 
		$(this).find('i').removeClass('icon-pause').addClass('icon-play')

$(document).on 'click', '#mix_stage #controls .minimize', (event) ->
	$('#mix_stage #controls').toggleClass('affixed manual')
	$('#_EMT').toggleClass('affixed manual')
	$('#mix_stage .collapse').collapse('toggle');
	$(this).find('i').toggleClass('icon-double-angle-up').toggleClass('icon-double-angle-down')


EMT.loadMix = (currentTrack) ->
	$('body').removeClass('stop-scrolling')
	EMT.highlightTrackPlaying()
	EMT.mixCard.closePopover()

	$('#mix_stage #controls').removeClass('affixed manual')
	$('#_EMT').removeClass('affixed manual')
	$('#mix_stage .collapse').collapse('show')
	$(this).find('i').addClass('icon-double-angle-up').removeClass('icon-double-angle-down')

	try 
		EMT.SC.stop()
		EMT.YT.stop()
	$track = $('.mix-tracks li:nth-child(' + currentTrack  + ')')
	if (parseInt($track.data('type'))==1)
		if(!_.isUndefined(EMT.YTPlayer) && !_.isUndefined(EMT.YTPlayer.loadVideoById))
			EMT.YT.load($track.data('url'))
		else
			temp = setInterval (->
				if(!_.isUndefined(EMT.YTPlayer.loadVideoById))
					clearInterval(temp)
					EMT.YT.load($track.data('url'))
			),250
	else 
		EMT.SC.load($track.data('url'))

EMT.highlightTrackPlaying = () ->
	$('.mix-tracks li').removeClass('active')
	$track = $('.mix-tracks li:nth-child(' + EMT.currentTrack  + ')')
	$track.addClass('active')
	$('.mix-tracks').scrollTo('.active',250)
