$("#SCPlayer").jPlayer()
	.bind($.jPlayer.event.timeupdate, (event) ->
    	currentTime = event.jPlayer.status.currentTime;
    	dur  = $("#SCPlayer").data("jPlayer").status.duration;
    	per = currentTime/dur * 100;
    	# console.log per
    	EMT.controls.progress(per)
    )
	.bind($.jPlayer.event.ended, (event) ->
    	EMT.controls.nextSong()
    )
    .bind($.jPlayer.event.error, (error) ->
		if($("#SCPlayer").data("jPlayer").status.src!='')
    		EMT.controls.nextSong()
    )


EMT.SoundCloud = () ->
	@load = (url) ->
		EMT.players.hide()
		scP = url.split("&");
		scId = scP[1].split("=")[1];
		playlink = 'http://api.soundcloud.com/tracks/' + scId + '/stream?client_id=002ef906c036a78c4cfad7c6c08a84dd'
		$("#SCPlayer").jPlayer( "setMedia", {mp3:playlink}).jPlayer("play");
		# MXT.marquee.changeMarquee("track",$(".pllS .songTitle").html()); 
		# MXT._cassette.startSpinning();
	@play = () ->
		$("#SCPlayer").jPlayer("play");
		# MXT._cassette.startSpinning();

	@stop = () ->
		$("#SCPlayer").jPlayer("clearMedia")

	@pause = () ->
		$("#SCPlayer").jPlayer("pause");
		# MXT._cassette.stopSpinning();

	@status = () ->
		$("#SCPlayer").data("jPlayer").status;

	@toggle = () ->
		if (@status().paused)
			@play()
			playing = true
		else 
			@pause()
			playing = false
		playing

	@volume = (vol) ->
		$("#SCPlayer").jPlayer("volume", vol);
	@

EMT.SC = new EMT.SoundCloud()