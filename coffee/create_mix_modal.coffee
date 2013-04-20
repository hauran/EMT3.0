$(document).on 'click', '#titleBar .create button', (event) ->
	if(!EMT.Partials.createMix)
		EMT.get '/create_mix_modal', {}, (partial)->
			EMT.Partials.createMix  = partial.view;
			$('body').append(EMT.Partials.createMix)
			$('#createMixModal').modal({show:true})
			$('#createMixModal input').first().focus()
	else
		$('#createMixModal').modal({show:true})
		$('#createMixModal input').first().focus()
