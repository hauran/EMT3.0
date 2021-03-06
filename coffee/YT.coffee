tag = document.createElement('script')
tag.src = "https://www.youtube.com/iframe_api"
firstScriptTag = document.getElementsByTagName('script')[0]
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)


EMT.YouTube = () ->
	@getCode = (url) ->
		pos = url.indexOf("v=")
		if(pos != -1)
			nextParam = url.indexOf("&",pos)
			if(nextParam == -1)
				return url.substring(pos+2)
			else
				return url.substring(pos+2,nextParam)
		else
			return ""


	@load = (url) ->
		EMT.players.show()
		EMT.YTPlayer.loadVideoById(@getCode(url));

	@play = () ->
		EMT.YTPlayer.playVideo()

	@pause = () ->
		EMT.YTPlayer.pauseVideo()

	@stop = () ->
		EMT.players.hide()
		# clearInterval(MXT.YTupdateInterval);
		EMT.YTPlayer.stopVideo()

	@onErrorNext = (event) ->
		EMT.controls.nextSong()
	
	@toggle = () ->
		status = EMT.YTPlayer.getPlayerState();
		if (status == 2) 
			@play()
			playing = true
		else if(status== 1)
			@pause()
			playing = false
		playing

	# @onPlayerReady = (event) ->
    	# event.target.playVideo()

	# done = false
	# @onPlayerStateChange = (event) ->
	# 	_this = EMT.YT
	# 	if (event.data == YT.PlayerState.PLAYING && !done)
	# 	  setTimeout(_this.stopVideo, 6000);
	# 	  done = true;

	@onPlayerStateChange = (event) ->
		_this = EMT.YT
		@getCurrentTimePer = () ->
			EMT.YTPlayer.getCurrentTime() / EMT.YTPlayer.getDuration() * 100

		if (event.data == YT.PlayerState.PLAYING) 
			# if(!EMT.isSR){
			console.log 'playing'
			EMT.YTupdateInterval = setInterval (->
				per = getCurrentTimePer()

				EMT.controls.progress(per)
				# console.log(per)
			), 500

			
			# }
			# else{
			# 	parent.postMessage(
			# 		JSON.stringify({func:'isSRPlaying'}),
			# 		domain
			# 	);
			# }
		
		else if(event.data == YT.PlayerState.PAUSED || event.data == YT.PlayerState.ENDED || event.data == YT.PlayerState.BUFFERING)
			console.log 'paused'
			clearInterval(EMT.YTupdateInterval)
			if(event.data == YT.PlayerState.ENDED)
				EMT.controls.nextSong()
		

	@


EMT.YT = new EMT.YouTube()
onYouTubeIframeAPIReady = () ->
	EMT.YTPlayer = new YT.Player('ytPlayer', {
		height: '390',
		width: '640',
		# videoId: 'M7lc1UVf-VE',
		# playerVars:{'autoplay':1, 'controls': 0},
		events: {
			'onError': EMT.YT.onErrorNext,
			# 'onReady': alert(1),
			'onStateChange': EMT.YT.onPlayerStateChange
		}
	})
		
