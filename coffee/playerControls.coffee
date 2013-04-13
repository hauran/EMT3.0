EMT.PlayerControls = () ->
	@.nextSong = () ->
		track = EMT.trackList[EMT.currentTrack]
		if(track.type==1)
			EMT.YT.load(track.url)

		EMT.currentTrack++
		EMT.pageRouter.navigate('/mix/' + EMT.mixId + '/' + EMT.currentTrack, {trigger:false, replace:true});

	@

EMT.controls = new EMT.PlayerControls()