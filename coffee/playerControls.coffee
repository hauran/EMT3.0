EMT.PlayerControls = () ->
	@nextSong = () ->
		clearInterval(EMT.YTupdateInterval)
		track = EMT.trackList[EMT.currentTrack]
		if(parseInt(track.type)==1)
			EMT.SC.stop()
			EMT.YT.load(track.url)
		else if(parseInt(track.type)==3)
			EMT.YT.stop()
			EMT.SC.load(track.url)
		else 
			EMT.currentTrack++
			@nextSong()
			return

		EMT.currentTrack++
		EMT.highlightTrackPlaying()
		EMT.pageRouter.navigate('/mix/' + EMT.mixId + '/' + EMT.currentTrack, {trigger:false, replace:false});

	@toggle = () ->
		currentTrack = EMT.trackList[EMT.currentTrack-1]
		if(parseInt(currentTrack.type)==1)
	 		return EMT.YT.toggle()
		else
			return EMT.SC.toggle()
	@progress = (per) ->
		$('#controls .progress .bar').css 'width', per
	@

EMT.controls = new EMT.PlayerControls()