EMT.PlayerControls = () ->
	@nextSong = () ->
		track = EMT.trackList[EMT.currentTrack]
		if(parseInt(track.type)==1)
			EMT.SC.stop()
			EMT.YT.load(track.url)
		else
			EMT.YT.stop()
			EMT.SC.load(track.url)

		EMT.currentTrack++
		EMT.highlightTrackPlaying()
		EMT.pageRouter.navigate('/mix/' + EMT.mixId + '/' + EMT.currentTrack, {trigger:false, replace:false});

	@toggle = () ->
		currentTrack = EMT.trackList[EMT.currentTrack-1]
		if(parseInt(currentTrack.type)==1)
	 		return EMT.YT.toggle()
		else
			return EMT.SC.toggle()

	@

EMT.controls = new EMT.PlayerControls()