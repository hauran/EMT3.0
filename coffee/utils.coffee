EMT.decodedCookie = (cookieName) ->
	encodedData = $.cookie(cookieName)
	if (encodedData) 
		if (encodedData.match(":isToken=1$") == null)
			return $.base64.decode(encodedData).split(":")
		else
			return encodedData.split(":")
	return null

EMT.post = (url, data, callback) ->
	url = EMT.phoneGapUrl(url)
	$.ajax({
      url:url
      data:data,
      cache: false,
      dataType:'json',
      type: 'POST',
      success: callback,
      timeout:60000
    });

EMT.get = (url, data, callback) ->
	url = EMT.phoneGapUrl(url)
	$.ajax({
      url:url
      data:data,
      cache: false,
      dataType:'json',
      type: 'GET',
      success: callback,
      timeout: 60000
    });

EMT.AjaxCall = (action, data, dataType, type, callback) ->
	action = EMT.phoneGapUrl(action)
	$.ajax {
		url:action,
		data:data,
		cache: false,
		dataType:dataType,
		type: type,
		success: callback,
		timeout: 60000
	}

EMT.phoneGapUrl = (url) ->
	if(EMT.PHONE_GAP)
		if(url.indexOf('/')!=0)
			url = EMT.PHONE_GAP_SERVER + "/" + url
		else 
			url = EMT.PHONE_GAP_SERVER + url
	url

EMT.redoLayout = () ->
	$('#leftBar').height($('#rightContent').height())
	$('.content-modal').height($('#rightContent').height())

$.ajaxSetup {
	timeout: 30000
	,beforeSend: (xhr) ->
		if ($.cookie(EMT.LOGIN_COOKIE))
			xhr.setRequestHeader "Authorization", "Basic " + $.cookie(EMT.LOGIN_COOKIE)
	,error: (jqXHR, textStatus, errorThrown)	->
		errorAction =  $.parseJSON(jqXHR.responseText);
		if jqXHR.status == 401		
			if errorAction.redirectURL
				$.removeCookie(EMT.LOGIN_COOKIE);
				$.cookie('nextAction', window.location.pathname, { path: '/' });
				EMT.pageRouter.navigate(errorAction.redirectURL, {trigger: true});
			else if errorAction.action
				EMT.last_logon_error = errorAction;
				EMT.pageRouter.navigate(errorAction.action, {trigger: true});
			else 
				$.removeCookie(EMT.LOGIN_COOKIE);
				EMT.pageRouter.navigate('/welcome', {trigger: true, replace:false});
}