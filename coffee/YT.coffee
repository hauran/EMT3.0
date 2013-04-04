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
	@
		
