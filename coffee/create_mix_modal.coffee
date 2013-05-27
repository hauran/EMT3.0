$(document).on 'click', '#titleBar .create button', (event) ->
	if(!EMT.Partials.createMix)
		EMT.renderPartial {}, 'create_mix_modal.html', (template) ->
			EMT.Partials.createMix  = template
			$('body').append(template)
			$('#createMixModal').modal({show:true})
			$('#createMixModal input').first().focus()

	else
		$('#createMixModal').modal({show:true})
		$('#createMixModal input').first().focus()
