var EMT, hammertime;

EMT = {};

EMT.HOME_PAGE = 'home';

EMT.PHONE_GAP = false;

EMT.LOGIN_COOKIE = 'emt_l';

EMT.partials = {};

EMT.meId;

EMT.meEmail;

EMT.YT;

EMT.BaseView = Backbone.View.extend({});

EMT.BaseModel = Backbone.Model.extend({});

EMT.PageModel = EMT.BaseModel.extend({});

EMT.PageView = EMT.BaseView.extend({
  el: $("body"),
  events: {
    "click .nav-link": "linkClick",
    "click .logout": "logout",
    "submit form.post-form": "postForm"
  },
  linkClick: function(e) {
    var $target, action;
    e.preventDefault();
    $target = $(e.target);
    action = $target.data('href');
    if (!(action != null)) {
      action = $target.closest('.nav-link').data('href');
    }
    if (!(action != null)) {
      action = e.target.pathname || e.currentTarget.pathname;
      if (e.target.search) {
        action = action + e.target.search;
      }
    }
    if (_.isUndefined(action)) {
      action = '/';
    }
    return EMT.pageRouter.navigate(action, {
      trigger: true,
      replace: false
    });
  },
  postForm: function(e) {
    var jsonData, postAction;
    e.preventDefault();
    postAction = $(e.target).attr('action');
    jsonData = $(e.target).serializeJSON();
    return EMT.post(postAction, jsonData, function(json) {
      return EMT.pageRouter.navigate(json.action, {
        trigger: true,
        replace: true
      });
    });
  },
  logout: function(e) {
    var location;
    e.preventDefault();
    $.removeCookie(EMT.LOGIN_COOKIE, {
      path: '/'
    });
    location = EMT.phoneGapUrl('welcome');
    return window.location.href = location;
  }
});

EMT.PageRouter = Backbone.Router.extend({
  routes: {
    '*action': 'fetchContent'
  },
  templateName: '',
  routerPageView: {},
  initialize: function() {
    var _pageModel;
    _pageModel = new EMT.PageModel();
    return this.routerPageView = new EMT.PageView({
      model: _pageModel
    });
  },
  fetchContent: function(action) {
    var highlight, _this;
    _this = this;
    if (action === '' || action === '/') {
      action = EMT.HOME_PAGE;
    } else {
      highlight = action;
      if (action.indexOf('/') > 0) {
        highlight = action.split('/')[0];
      }
      action = '/' + action;
    }
    if (EMT.PHONE_GAP) {
      if (action.indexOf('www') !== -1) {
        action = action.substr(action.indexOf('www') + 4);
        if (action === 'index.html') {
          action = "/home";
        }
      }
    }
    return EMT.get(action, null, function(json) {
      return _this._pageViewSetModel(json);
    });
  },
  _pageViewSetModel: function(json) {
    $('#_EMT').html(Mustache.render(json.view, json.payload, json.payload.data.partials));
    return $(window).scrollTop(0);
  }
});

(function($) {
  return $.fn.serializeJSON = function() {
    var json;
    json = {};
    jQuery.map($(this).serializeArray(), function(n, i) {
      return json[n["name"]] = n["value"];
    });
    return json;
  };
})(jQuery);

hammertime = $(document).hammer();

$(document).ready(function() {
  EMT.pageRouter = new EMT.PageRouter();
  Backbone.history.start({
    pushState: true
  });
  return EMT.YT = new EMT.YouTube();
});

EMT.decodedCookie = function(cookieName) {
  var encodedData;
  encodedData = $.cookie(cookieName);
  if (encodedData) {
    if (encodedData.match(":isToken=1$") === null) {
      return $.base64.decode(encodedData).split(":");
    } else {
      return encodedData.split(":");
    }
  }
  return null;
};

EMT.post = function(url, data, callback) {
  url = EMT.phoneGapUrl(url);
  return $.ajax({
    url: url,
    data: data,
    cache: false,
    dataType: 'json',
    type: 'POST',
    success: callback
  });
};

EMT.get = function(url, data, callback) {
  url = EMT.phoneGapUrl(url);
  return $.ajax({
    url: url,
    data: data,
    cache: false,
    dataType: 'json',
    type: 'GET',
    success: callback
  });
};

EMT.AjaxCall = function(action, data, dataType, type, callback) {
  action = EMT.phoneGapUrl(action);
  return $.ajax({
    url: action,
    data: data,
    cache: false,
    dataType: dataType,
    type: type,
    success: callback
  });
};

EMT.phoneGapUrl = function(url) {
  if (EMT.PHONE_GAP) {
    if (url.indexOf('/') !== 0) {
      url = EMT.PHONE_GAP_SERVER + "/" + url;
    } else {
      url = EMT.PHONE_GAP_SERVER + url;
    }
  }
  return url;
};

EMT.redoLayout = function() {
  $('#leftBar').height($('#rightContent').height());
  return $('.content-modal').height($('#rightContent').height());
};

$.ajaxSetup({
  timeout: 30000,
  beforeSend: function(xhr) {
    if ($.cookie(EMT.LOGIN_COOKIE)) {
      return xhr.setRequestHeader("Authorization", "Basic " + $.cookie(EMT.LOGIN_COOKIE));
    }
  },
  error: function(jqXHR, textStatus, errorThrown) {
    var errorAction;
    errorAction = $.parseJSON(jqXHR.responseText);
    if (jqXHR.status === 401) {
      if (errorAction.redirectURL) {
        $.removeCookie(EMT.LOGIN_COOKIE);
        $.cookie('nextAction', window.location.pathname, {
          path: '/'
        });
        return EMT.pageRouter.navigate(errorAction.redirectURL, {
          trigger: true
        });
      } else if (errorAction.action) {
        EMT.last_logon_error = errorAction;
        return EMT.pageRouter.navigate(errorAction.action, {
          trigger: true
        });
      } else {
        $.removeCookie(EMT.LOGIN_COOKIE);
        return EMT.pageRouter.navigate('/welcome', {
          trigger: true,
          replace: false
        });
      }
    }
  }
});

EMT.YouTube = function() {
  this.getCode = function(url) {
    var nextParam, pos;
    pos = url.indexOf("v=");
    if (pos !== -1) {
      nextParam = url.indexOf("&", pos);
      if (nextParam === -1) {
        return url.substring(pos + 2);
      } else {
        return url.substring(pos + 2, nextParam);
      }
    } else {
      return "";
    }
  };
  return this;
};
