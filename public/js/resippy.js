var APP, hammertime, socket, socketio_connect;

APP = {};

APP.PHONE_GAP = false;

APP.PHONE_GAP_SERVER = "http://localhost:8080";

APP.HOME_PAGE = 'coming_soon';

APP.LOGIN_COOKIE = 'rspy_l';

APP.partials = {};

APP.meId;

APP.meEmail;

APP.BaseView = Backbone.View.extend({});

APP.BaseModel = Backbone.Model.extend({});

APP.PageModel = APP.BaseModel.extend({});

APP.PageView = APP.BaseView.extend({
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
    return APP.pageRouter.navigate(action, {
      trigger: true,
      replace: false
    });
  },
  postForm: function(e) {
    var jsonData, postAction;
    e.preventDefault();
    postAction = $(e.target).attr('action');
    jsonData = $(e.target).serializeJSON();
    return APP.post(postAction, jsonData, function(json) {
      return APP.pageRouter.navigate(json.action, {
        trigger: true,
        replace: true
      });
    });
  },
  logout: function(e) {
    var location;
    e.preventDefault();
    $.removeCookie(APP.LOGIN_COOKIE, {
      path: '/'
    });
    location = APP.phoneGapUrl('welcome');
    return window.location.href = location;
  }
});

APP.PageRouter = Backbone.Router.extend({
  routes: {
    '*action': 'fetchContent'
  },
  templateName: '',
  routerPageView: {},
  initialize: function() {
    var _pageModel;
    _pageModel = new APP.PageModel();
    return this.routerPageView = new APP.PageView({
      model: _pageModel
    });
  },
  fetchContent: function(action) {
    var highlight, _this;
    _this = this;
    if (action === '' || action === '/') {
      action = APP.HOME_PAGE;
    } else {
      highlight = action;
      if (action.indexOf('/') > 0) {
        highlight = action.split('/')[0];
      }
      action = '/' + action;
    }
    if (APP.PHONE_GAP) {
      if (action.indexOf('www') !== -1) {
        action = action.substr(action.indexOf('www') + 4);
        if (action === 'index.html') {
          action = "/home";
        }
      }
    }
    return APP.get(action, null, function(json) {
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
  APP.pageRouter = new APP.PageRouter();
  return Backbone.history.start({
    pushState: true
  });
});

socket = io.connect(window.location.origin);

socket.on('new_post', function(data) {
  return APP.newPost(data.payload);
});

socket.on('ill_do_it', function(data) {
  return APP.updatePostStats(data);
});

socket.on('maybe_do_it', function(data) {
  return APP.updatePostStats(data);
});

socket.on('not_gonna_do_it', function(data) {
  return APP.updatePostStats(data);
});

socketio_connect = function() {
  return socket.emit('signedIn', APP.meEmail);
};

APP.decodedCookie = function(cookieName) {
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

APP.post = function(url, data, callback) {
  url = APP.phoneGapUrl(url);
  return $.ajax({
    url: url,
    data: data,
    cache: false,
    dataType: 'json',
    type: 'POST',
    success: callback
  });
};

APP.get = function(url, data, callback) {
  url = APP.phoneGapUrl(url);
  return $.ajax({
    url: url,
    data: data,
    cache: false,
    dataType: 'json',
    type: 'GET',
    success: callback
  });
};

APP.AjaxCall = function(action, data, dataType, type, callback) {
  action = APP.phoneGapUrl(action);
  return $.ajax({
    url: action,
    data: data,
    cache: false,
    dataType: dataType,
    type: type,
    success: callback
  });
};

APP.phoneGapUrl = function(url) {
  if (APP.PHONE_GAP) {
    if (url.indexOf('/') !== 0) {
      url = APP.PHONE_GAP_SERVER + "/" + url;
    } else {
      url = APP.PHONE_GAP_SERVER + url;
    }
  }
  return url;
};

APP.redoLayout = function() {
  $('#leftBar').height($('#rightContent').height());
  return $('.content-modal').height($('#rightContent').height());
};

$.ajaxSetup({
  timeout: 30000,
  beforeSend: function(xhr) {
    if ($.cookie(APP.LOGIN_COOKIE)) {
      return xhr.setRequestHeader("Authorization", "Basic " + $.cookie(APP.LOGIN_COOKIE));
    }
  },
  error: function(jqXHR, textStatus, errorThrown) {
    var errorAction;
    errorAction = $.parseJSON(jqXHR.responseText);
    if (jqXHR.status === 401) {
      if (errorAction.redirectURL) {
        $.removeCookie(APP.LOGIN_COOKIE);
        $.cookie('nextAction', window.location.pathname, {
          path: '/'
        });
        return APP.pageRouter.navigate(errorAction.redirectURL, {
          trigger: true
        });
      } else if (errorAction.action) {
        APP.last_logon_error = errorAction;
        return APP.pageRouter.navigate(errorAction.action, {
          trigger: true
        });
      } else {
        $.removeCookie(APP.LOGIN_COOKIE);
        return APP.pageRouter.navigate('/welcome', {
          trigger: true,
          replace: false
        });
      }
    }
  }
});

APP.AjaxCall('/templates/partials/posts.html', {}, 'text', 'GET', function(partial) {
  return APP.partials.postPartial = Mustache.compile(partial);
});

APP.AjaxCall('/templates/partials/ill_do_it_list.html', {}, 'text', 'GET', function(partial) {
  return APP.partials.illDoIt = Mustache.compile(partial);
});

APP.AjaxCall('/templates/partials/maybe_do_it_list.html', {}, 'text', 'GET', function(partial) {
  return APP.partials.maybeDoIt = Mustache.compile(partial);
});

APP.newPost = function(post) {
  $('#rightContent').prepend(APP.partials.postPartial(post)).masonry('reload');
  $('.time-ago').timeago();
  return APP.redoLayout();
};

APP.getPosts = function() {
  return APP.get('/posts', {}, function(posts) {
    $('#rightContent').empty();
    _.each(posts.payload.data.posts, function(post) {
      return $('#rightContent').append(APP.partials.postPartial(post));
    });
    $('#rightContent').masonry('reload');
    $('.time-ago').timeago();
    return APP.redoLayout();
  });
};

APP.updatePostStats = function(data) {
  var $post, stats;
  stats = data.payload;
  if (stats.data) {
    stats = stats.data;
  }
  if (stats.not_gonna_do_it) {
    stats = stats.not_gonna_do_it;
  } else if (stats.ill_do_it) {
    stats = stats.ill_do_it;
  } else if (stats.maybe_do_it) {
    stats = stats.maybe_do_it;
  }
  $post = $('.post#' + stats.post);
  if (stats.illDoIt && stats.illDoIt.length > 0) {
    stats = _.extend(stats, {
      illDoIt_count: stats.illDoIt.length
    });
    $post.find('div.ill-do-it').html(APP.partials.illDoIt(stats));
  } else {
    $post.find('div.ill-do-it').empty();
  }
  if (stats.maybe && stats.maybe.length > 0) {
    stats = _.extend(stats, {
      maybe_count: stats.maybe.length
    });
    $post.find('div.maybe').html(APP.partials.maybeDoIt(stats));
  } else {
    $post.find('div.maybe').empty();
  }
  return setTimeout(function() {
    return $('#rightContent').masonry('reload');
  }, 500);
};

hammertime.on("tap", ".post", function(ev) {
  var $action, $post, leftPos, postedBy;
  $post = $(this);
  postedBy = $post.data('postedby');
  $action = $post.find('.action');
  if (postedBy === APP.meId) {
    return;
  }
  leftPos = $post.css('left');
  if ($post.hasClass('active')) {
    $action.collapse('hide');
    $('.post.active .action').collapse('hide');
    $('.post.active').removeClass('active');
    $('.post.moveDown').removeClass('moveDown');
  } else {
    $('.post.active .action').collapse('hide');
    $('.post.active').removeClass('active');
    $('.post.moveDown').removeClass('moveDown');
    $action.collapse('show');
    $post.addClass('active');
    $post.nextAll('.post').filter(function() {
      return $(this).css('left') === leftPos;
    }).addClass('moveDown');
  }
  return ev.stopPropagation();
});

hammertime.on("tap", ".post .action-btns", function(ev) {
  return ev.stopPropagation();
});

hammertime.on("tap", ".btn.illDoIt", function(ev) {
  var $action, $this, post;
  $this = $(this);
  $action = $this.closest('.action');
  post = $action.data('id');
  $this.siblings('.maybe').removeClass('active').find('.icon-check').addClass('hide');
  if (!$this.hasClass('active')) {
    $this.find('.icon-check').removeClass('hide');
    return APP.post('/post/ill_do_it', {
      post: post
    }, function(data) {
      APP.updatePostStats(data);
      $this.addClass('active');
      return $('.post#' + post).trigger('tap');
    });
  } else {
    $this.find('.icon-check').addClass('hide');
    return APP.post('/post/not_gonna_do_it', {
      post: post
    }, function(data) {
      APP.updatePostStats(data);
      $this.removeClass('active');
      return $('.post#' + post).trigger('tap');
    });
  }
});

hammertime.on("tap", ".btn.maybe", function(ev) {
  var $action, $this, post;
  $this = $(this);
  $action = $this.closest('.action');
  post = $action.data('id');
  $this.siblings('.illDoIt').removeClass('active').find('.icon-check').addClass('hide');
  if (!$this.hasClass('active')) {
    $this.find('.icon-check').removeClass('hide');
    return APP.post('/post/maybe_do_it', {
      post: post
    }, function(data) {
      APP.updatePostStats(data);
      $this.addClass('active');
      return $('.post#' + post).trigger('tap');
    });
  } else {
    $this.find('.icon-check').addClass('hide');
    return APP.post('/post/not_gonna_do_it', {
      post: post
    }, function(data) {
      APP.updatePostStats(data);
      $this.removeClass('active');
      return $('.post#' + post).trigger('tap');
    });
  }
});

APP.AjaxCall('/templates/partials/person_listing.html', {}, 'text', 'GET', function(plp) {
  return APP.partials.personListingPartial = Mustache.compile(plp);
});

APP.newPersonListing = function(person) {
  return $('.friend-listing').prepend(APP.partials.personListingPartial(person));
};
