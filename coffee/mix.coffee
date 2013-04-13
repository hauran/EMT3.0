$(document).on 'click', '#mix_stage ul.mix-tracks li', (event) ->
	EMT.currentTrack = $(this).index()
	EMT.controls.nextSong()
	# id = $(this).closest('.popover').siblings('.mixCard').data('id')
	# EMT.mixId = id
	# track = $(this).index()+1
	# EMT.pageRouter.navigate('/mix/' + id + '/' + track, {trigger:true, replace:true});