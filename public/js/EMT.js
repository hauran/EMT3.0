var EMT,firstScriptTag,hammertime,mixcard,onYouTubeIframeAPIReady,tag;EMT={},EMT.HOME_PAGE="home",EMT.PHONE_GAP=!1,EMT.LOGIN_COOKIE="emt_l",EMT.partials={},EMT.meId,EMT.meEmail,EMT.controls,EMT.YT,EMT.YTPlayer,EMT.YTupdateInterval,EMT.SC,EMT.SCID="002ef906c036a78c4cfad7c6c08a84dd",EMT.mixId,EMT.trackList,EMT.currentTrack,EMT.mixCard,EMT.BaseView=Backbone.View.extend({}),EMT.BaseModel=Backbone.Model.extend({}),EMT.PageModel=EMT.BaseModel.extend({}),EMT.Partials={},EMT.PageView=EMT.BaseView.extend({el:$("body"),events:{"click .nav-link":"linkClick","click .logout":"logout","submit form.post-form":"postForm"},linkClick:function(e){var t,r;return e.preventDefault(),t=$(e.target),r=t.data("href"),null==r&&(r=t.closest(".nav-link").data("href")),null==r&&(r=e.target.pathname||e.currentTarget.pathname,e.target.search&&(r+=e.target.search)),_.isUndefined(r)&&(r="/"),EMT.pageRouter.navigate(r,{trigger:!0,replace:!1})},postForm:function(e){var t,r;return e.preventDefault(),r=$(e.target).attr("action"),t=$(e.target).serializeJSON(),EMT.post(r,t,function(e){return EMT.pageRouter.navigate(e.action,{trigger:!0,replace:!0})})},logout:function(e){var t;return e.preventDefault(),$.removeCookie(EMT.LOGIN_COOKIE,{path:"/"}),t=EMT.phoneGapUrl("welcome"),window.location.href=t}}),EMT.PageRouter=Backbone.Router.extend({routes:{"*action":"fetchContent"},templateName:"",routerPageView:{},initialize:function(){var e;return e=new EMT.PageModel,this.routerPageView=new EMT.PageView({model:e})},fetchContent:function(e){var t,r;return r=this,""===e||"/"===e?e=EMT.HOME_PAGE:(t=e,e.indexOf("/")>0&&(t=e.split("/")[0]),e="/"+e),EMT.PHONE_GAP&&-1!==e.indexOf("www")&&(e=e.substr(e.indexOf("www")+4),"index.html"===e&&(e="/home")),EMT.get(e,null,function(e){return r._pageViewSetModel(e)})},_pageViewSetModel:function(e){return $("#_EMT").html(Mustache.render(e.view,e.payload,e.payload.data.partials)),$(window).scrollTop(0)}}),function(e){return e.fn.serializeJSON=function(){var t;return t={},jQuery.map(e(this).serializeArray(),function(e){return t[e.name]=e.value}),t}}(jQuery),hammertime=$(document).hammer(),$(document).ready(function(){return EMT.pageRouter=new EMT.PageRouter,Backbone.history.start({pushState:!0}),$(document).click(function(){return $(".mixCard").popover("hide")})}),EMT.decodedCookie=function(e){var t;return t=$.cookie(e),t?null===t.match(":isToken=1$")?$.base64.decode(t).split(":"):t.split(":"):null},EMT.post=function(e,t,r){return e=EMT.phoneGapUrl(e),$.ajax({url:e,data:t,cache:!1,dataType:"json",type:"POST",success:r})},EMT.get=function(e,t,r){return e=EMT.phoneGapUrl(e),$.ajax({url:e,data:t,cache:!1,dataType:"json",type:"GET",success:r})},EMT.AjaxCall=function(e,t,r,a,n){return e=EMT.phoneGapUrl(e),$.ajax({url:e,data:t,cache:!1,dataType:r,type:a,success:n})},EMT.phoneGapUrl=function(e){return EMT.PHONE_GAP&&(e=0!==e.indexOf("/")?EMT.PHONE_GAP_SERVER+"/"+e:EMT.PHONE_GAP_SERVER+e),e},EMT.customRadiosAndCheckboxes=function(){return $(".checkbox, .radio").prepend("<span class='icon'></span><span class='icon-to-fade'></span>"),$(".checkbox, .radio").click(function(){return setupLabel()}),setupLabel()},EMT.customToggle=function(){return $(".toggle").each(function(e,t){return toggleHandler(t)})},$.ajaxSetup({timeout:6e4,beforeSend:function(e){return $.cookie(EMT.LOGIN_COOKIE)?e.setRequestHeader("Authorization","Basic "+$.cookie(EMT.LOGIN_COOKIE)):void 0},error:function(e){var t;return t=$.parseJSON(e.responseText),401===e.status?t.redirectURL?($.removeCookie(EMT.LOGIN_COOKIE),$.cookie("nextAction",window.location.pathname,{path:"/"}),EMT.pageRouter.navigate(t.redirectURL,{trigger:!0})):t.action?(EMT.last_logon_error=t,EMT.pageRouter.navigate(t.action,{trigger:!0})):($.removeCookie(EMT.LOGIN_COOKIE),EMT.pageRouter.navigate("/welcome",{trigger:!0,replace:!1})):void 0}}),tag=document.createElement("script"),tag.src="https://www.youtube.com/iframe_api",firstScriptTag=document.getElementsByTagName("script")[0],firstScriptTag.parentNode.insertBefore(tag,firstScriptTag),EMT.YouTube=function(){return this.getCode=function(e){var t,r;return r=e.indexOf("v="),-1!==r?(t=e.indexOf("&",r),-1===t?e.substring(r+2):e.substring(r+2,t)):""},this.load=function(e){return EMT.YTPlayer.loadVideoById(this.getCode(e))},this.play=function(){return EMT.YTPlayer.playVideo()},this.pause=function(){return EMT.YTPlayer.pauseVideo()},this.stop=function(){return EMT.YTPlayer.stopVideo()},this.onErrorNext=function(){return EMT.controls.nextSong()},this.toggle=function(){var e,t;return t=EMT.YTPlayer.getPlayerState(),2===t?(this.play(),e=!0):1===t&&(this.pause(),e=!1),e},this.onPlayerStateChange=function(e){var t;return t=EMT.YT,this.getCurrentTimePer=function(){return 100*(EMT.YTPlayer.getCurrentTime()/EMT.YTPlayer.getDuration())},e.data===YT.PlayerState.PLAYING?EMT.YTupdateInterval=setInterval(function(){var e;return e=getCurrentTimePer()},500):e.data!==YT.PlayerState.PAUSED&&e.data!==YT.PlayerState.ENDED&&e.data!==YT.PlayerState.BUFFERING||(clearInterval(EMT.YTupdateInterval),e.data!==YT.PlayerState.ENDED)?void 0:EMT.controls.nextSong()},this},EMT.YT=new EMT.YouTube,onYouTubeIframeAPIReady=function(){return EMT.YTPlayer=new YT.Player("ytPlayer",{height:"390",width:"640",events:{onError:EMT.YT.onErrorNext,onStateChange:EMT.YT.onPlayerStateChange}})},$("#SCPlayer").jPlayer().bind($.jPlayer.event.timeupdate,function(e){var t,r,a;return t=e.jPlayer.status.currentTime,r=$("#SCPlayer").data("jPlayer").status.duration,a=100*(t/r)}).bind($.jPlayer.event.ended,function(){return EMT.controls.nextSong()}).bind($.jPlayer.event.error,function(){},""!==$("#SCPlayer").data("jPlayer").status.src?EMT.controls.nextSong():void 0),EMT.SoundCloud=function(){return this.load=function(e){var t,r,a;return a=e.split("&"),r=a[1].split("=")[1],t="http://api.soundcloud.com/tracks/"+r+"/stream?client_id=002ef906c036a78c4cfad7c6c08a84dd",$("#SCPlayer").jPlayer("setMedia",{mp3:t}).jPlayer("play")},this.play=function(){return $("#SCPlayer").jPlayer("play")},this.stop=function(){return $("#SCPlayer").jPlayer("clearMedia")},this.pause=function(){return $("#SCPlayer").jPlayer("pause")},this.status=function(){return $("#SCPlayer").data("jPlayer").status},this.toggle=function(){var e;return this.status().paused?(this.play(),e=!0):(this.pause(),e=!1),e},this.volume=function(e){return $("#SCPlayer").jPlayer("volume",e)},this},EMT.SC=new EMT.SoundCloud,EMT.PlayerControls=function(){return this.nextSong=function(){var e;return e=EMT.trackList[EMT.currentTrack],1===parseInt(e.type)?(EMT.SC.stop(),EMT.YT.load(e.url)):(EMT.YT.stop(),EMT.SC.load(e.url)),EMT.currentTrack++,EMT.pageRouter.navigate("/mix/"+EMT.mixId+"/"+EMT.currentTrack,{trigger:!1,replace:!1})},this.toggle=function(){var e;return e=EMT.trackList[EMT.currentTrack-1],1===parseInt(e.type)?EMT.YT.toggle():EMT.SC.toggle()},this},EMT.controls=new EMT.PlayerControls,mixcard=function(){return this.showPopover=-1,this.hidePopover=null,this.closePopover=function(){var e;return e=this,setTimeout(function(){return e.hidePopover?$(".mixCard").popover("hide").removeClass("hover"):void 0},500)},this.placement=function(){var e,t;return e=$(".mixCard.hover"),t=e.offset().left+e.width()+250,t>$(window).width()?"left":"right"},this},EMT.mixCard=new mixcard,$(document).hoverIntent({over:function(){var e;return setTimeout(function(){return EMT.mixCard.hidePopover=!1},100),e=this,0===$(e).siblings(".popover").length&&($(".mixCard").popover("hide").removeClass("hover"),$(e).addClass("hover"),$(e).popover("show"),$(".popover").css("top",$(e).offset().top-50+"px")),EMT.get("/mixcard_tracks_popover/"+$(e).data("id"),{},function(t){var r,a;return a=t.payload.data.partials.mixcard_tracks_popover,r=$(e).attr("data-content",Mustache.render(a,t.payload)).data("popover"),r.setContent(),r.$tip.addClass(r.options.placement),$(".popover-content ul li:nth-child(10)").addClass("hide-after"),$(".popover-content ul li:nth-child(11)")[0]?$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter("li.hide-after"):void 0})},out:function(){return EMT.mixCard.hidePopover=!0,EMT.mixCard.closePopover()},selector:".mixCard"}),$(document).on("mouseenter",".popover",function(){return setTimeout(function(){return EMT.mixCard.hidePopover=!1},100)}),$(document).on("mouseleave",".popover",function(){return EMT.mixCard.hidePopover=!0,EMT.mixCard.closePopover()}),$(document).on("click",".mixCard",function(){var e;return e=$(this).data("id"),EMT.mixId=e,EMT.pageRouter.navigate("/mix/"+e+"/1",{trigger:!0,replace:!0})}),$(document).on("click",".popover ul.mix-tracks li:not(.more)",function(){var e,t;return e=$(this).closest(".popover").siblings(".mixCard").data("id"),EMT.mixId=e,t=$(this).index()+1,EMT.pageRouter.navigate("/mix/"+e+"/"+t,{trigger:!0,replace:!0})}),$(document).on("click",".popover ul.mix-tracks li.more",function(e){return e.stopPropagation(),$(this).remove(),$("ul.mix-tracks li.hide-after").removeClass("hide-after")}),$(document).on("click","#mix_stage ul.mix-tracks li",function(){return EMT.currentTrack=$(this).index(),EMT.controls.nextSong(),EMT.highlightTrackPlaying()}),$(document).on("click","#mix_stage .next",function(){return EMT.controls.nextSong(),EMT.highlightTrackPlaying()}),$(document).on("click","#mix_stage .play-pause",function(){var e;return e=EMT.controls.toggle(),e?$(this).find("i").removeClass("icon-play").addClass("icon-pause"):$(this).find("i").removeClass("icon-pause").addClass("icon-play")}),EMT.loadMix=function(e){var t,r;return EMT.highlightTrackPlaying(),t=$(".mix-tracks li:nth-child("+e+")"),1===parseInt(t.data("type"))?_.isUndefined(EMT.YTPlayer)||_.isUndefined(EMT.YTPlayer.loadVideoById)?r=setInterval(function(){return _.isUndefined(EMT.YTPlayer.loadVideoById)?void 0:(clearInterval(r),EMT.YT.load(t.data("url")))},250):EMT.YT.load(t.data("url")):EMT.SC.load(t.data("url"))},EMT.highlightTrackPlaying=function(){var e;return $(".mix-tracks li").removeClass("active"),e=$(".mix-tracks li:nth-child("+EMT.currentTrack+")"),e.addClass("active")},$(document).on("click","#titleBar .create button",function(){return EMT.Partials.createMix?($("#createMixModal").modal({show:!0}),$("#createMixModal input").first().focus()):EMT.get("/create_mix_modal",{},function(e){return EMT.Partials.createMix=e.view,$("body").append(EMT.Partials.createMix),$("#createMixModal").modal({show:!0}),$("#createMixModal input").first().focus()})});