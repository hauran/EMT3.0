EMT.Players = () ->
	@hide = () ->
		$('#players').addClass('min')
	@show = () ->
		$('#players').removeClass('min')

	@

EMT.players = new EMT.Players()