var EMT,firstScriptTag,hammertime,mixcard,onYouTubeIframeAPIReady,tag;EMT={},EMT.HOME_PAGE="home",EMT.PHONE_GAP=!1,EMT.LOGIN_COOKIE="emt_l",EMT.partials={},EMT.meId,EMT.meEmail,EMT.controls,EMT.YT,EMT.YTPlayer,EMT.YTupdateInterval,EMT.mixId,EMT.trackList,EMT.currentTrack,EMT.mixCard,EMT.BaseView=Backbone.View.extend({}),EMT.BaseModel=Backbone.Model.extend({}),EMT.PageModel=EMT.BaseModel.extend({}),EMT.PageView=EMT.BaseView.extend({el:$("body"),events:{"click .nav-link":"linkClick","click .logout":"logout","submit form.post-form":"postForm"},linkClick:function(e){var t,r;return e.preventDefault(),t=$(e.target),r=t.data("href"),null==r&&(r=t.closest(".nav-link").data("href")),null==r&&(r=e.target.pathname||e.currentTarget.pathname,e.target.search&&(r+=e.target.search)),_.isUndefined(r)&&(r="/"),EMT.pageRouter.navigate(r,{trigger:!0,replace:!1})},postForm:function(e){var t,r;return e.preventDefault(),r=$(e.target).attr("action"),t=$(e.target).serializeJSON(),EMT.post(r,t,function(e){return EMT.pageRouter.navigate(e.action,{trigger:!0,replace:!0})})},logout:function(e){var t;return e.preventDefault(),$.removeCookie(EMT.LOGIN_COOKIE,{path:"/"}),t=EMT.phoneGapUrl("welcome"),window.location.href=t}}),EMT.PageRouter=Backbone.Router.extend({routes:{"*action":"fetchContent"},templateName:"",routerPageView:{},initialize:function(){var e;return e=new EMT.PageModel,this.routerPageView=new EMT.PageView({model:e})},fetchContent:function(e){var t,r;return r=this,""===e||"/"===e?e=EMT.HOME_PAGE:(t=e,e.indexOf("/")>0&&(t=e.split("/")[0]),e="/"+e),EMT.PHONE_GAP&&-1!==e.indexOf("www")&&(e=e.substr(e.indexOf("www")+4),"index.html"===e&&(e="/home")),EMT.get(e,null,function(e){return r._pageViewSetModel(e)})},_pageViewSetModel:function(e){return $("#_EMT").html(Mustache.render(e.view,e.payload,e.payload.data.partials)),$(window).scrollTop(0)}}),function(e){return e.fn.serializeJSON=function(){var t;return t={},jQuery.map(e(this).serializeArray(),function(e){return t[e.name]=e.value}),t}}(jQuery),hammertime=$(document).hammer(),$(document).ready(function(){return EMT.pageRouter=new EMT.PageRouter,Backbone.history.start({pushState:!0}),$(document).click(function(){return $(".mixCard").popover("hide")})}),EMT.decodedCookie=function(e){var t;return t=$.cookie(e),t?null===t.match(":isToken=1$")?$.base64.decode(t).split(":"):t.split(":"):null},EMT.post=function(e,t,r){return e=EMT.phoneGapUrl(e),$.ajax({url:e,data:t,cache:!1,dataType:"json",type:"POST",success:r})},EMT.get=function(e,t,r){return e=EMT.phoneGapUrl(e),$.ajax({url:e,data:t,cache:!1,dataType:"json",type:"GET",success:r})},EMT.AjaxCall=function(e,t,r,n,o){return e=EMT.phoneGapUrl(e),$.ajax({url:e,data:t,cache:!1,dataType:r,type:n,success:o})},EMT.phoneGapUrl=function(e){return EMT.PHONE_GAP&&(e=0!==e.indexOf("/")?EMT.PHONE_GAP_SERVER+"/"+e:EMT.PHONE_GAP_SERVER+e),e},EMT.redoLayout=function(){return $("#leftBar").height($("#rightContent").height()),$(".content-modal").height($("#rightContent").height())},$.ajaxSetup({timeout:6e4,beforeSend:function(e){return $.cookie(EMT.LOGIN_COOKIE)?e.setRequestHeader("Authorization","Basic "+$.cookie(EMT.LOGIN_COOKIE)):void 0},error:function(e){var t;return t=$.parseJSON(e.responseText),401===e.status?t.redirectURL?($.removeCookie(EMT.LOGIN_COOKIE),$.cookie("nextAction",window.location.pathname,{path:"/"}),EMT.pageRouter.navigate(t.redirectURL,{trigger:!0})):t.action?(EMT.last_logon_error=t,EMT.pageRouter.navigate(t.action,{trigger:!0})):($.removeCookie(EMT.LOGIN_COOKIE),EMT.pageRouter.navigate("/welcome",{trigger:!0,replace:!1})):void 0}}),tag=document.createElement("script"),tag.src="https://www.youtube.com/iframe_api",firstScriptTag=document.getElementsByTagName("script")[0],firstScriptTag.parentNode.insertBefore(tag,firstScriptTag),EMT.YouTube=function(){return this.getCode=function(e){var t,r;return r=e.indexOf("v="),-1!==r?(t=e.indexOf("&",r),-1===t?e.substring(r+2):e.substring(r+2,t)):""},this.load=function(e){return EMT.YTPlayer.loadVideoById(this.getCode(e))},this.play=function(){return this},this.pause=function(){return this},this.stopVideo=function(){var e;return e=this,EMT.YTPlayer.stopVideo()},this.onErrorNext=function(){return EMT.controls.nextSong()},this.toggle=function(){var e;return e=EMT.YTPlayer.getPlayerState(),2===e?this.play():1===e?this.pause():void 0},this.onPlayerStateChange=function(e){var t;return t=EMT.YT,this.getCurrentTimePer=function(){return 100*(EMT.YTPlayer.getCurrentTime()/EMT.YTPlayer.getDuration())},e.data===YT.PlayerState.PLAYING?EMT.YTupdateInterval=setInterval(function(){var e;return e=getCurrentTimePer()},500):e.data!==YT.PlayerState.PAUSED&&e.data!==YT.PlayerState.ENDED&&e.data!==YT.PlayerState.BUFFERING||(clearInterval(EMT.YTupdateInterval),e.data!==YT.PlayerState.ENDED)?void 0:EMT.controls.nextSong()},this},EMT.YT=new EMT.YouTube,onYouTubeIframeAPIReady=function(){return EMT.YTPlayer=new YT.Player("ytPlayer",{height:"390",width:"640",events:{onError:EMT.YT.onErrorNext,onStateChange:EMT.YT.onPlayerStateChange}})},EMT.PlayerControls=function(){return this.nextSong=function(){var e;return e=EMT.trackList[EMT.currentTrack],1===e.type&&EMT.YT.load(e.url),EMT.currentTrack++,EMT.pageRouter.navigate("/mix/"+EMT.mixId+"/"+EMT.currentTrack,{trigger:!1,replace:!0})},this},EMT.controls=new EMT.PlayerControls,mixcard=function(){return this.showPopover=-1,this.hidePopover=null,this.closePopover=function(){var e;return e=this,setTimeout(function(){return e.hidePopover?$(".mixCard").popover("hide").removeClass("hover"):void 0},500)},this.placement=function(){var e,t;return e=$(".mixCard.hover"),t=e.offset().left+e.width()+250,t>$(window).width()?"left":"right"},this},EMT.mixCard=new mixcard,$(document).hoverIntent({over:function(){var e;return setTimeout(function(){return EMT.mixCard.hidePopover=!1},100),e=this,0===$(e).siblings(".popover").length&&($(".mixCard").popover("hide").removeClass("hover"),$(e).addClass("hover"),$(e).popover("show"),$(".popover").css("top",$(e).offset().top-50+"px")),EMT.get("/mixcard_tracks_popover/"+$(e).data("id"),{},function(t){var r,n;return n=t.payload.data.partials.mixcard_tracks_popover,r=$(e).attr("data-content",Mustache.render(n,t.payload)).data("popover"),r.setContent(),r.$tip.addClass(r.options.placement),$(".popover-content ul li:nth-child(10)").addClass("hide-after"),$(".popover-content ul li:nth-child(11)")[0]?$('<li class="more"><div><i class="icon-sort-down"/></div>more</li>').insertAfter("li.hide-after"):void 0})},out:function(){return EMT.mixCard.hidePopover=!0,EMT.mixCard.closePopover()},selector:".mixCard"}),$(document).on("mouseenter",".popover",function(){return setTimeout(function(){return EMT.mixCard.hidePopover=!1},100)}),$(document).on("mouseleave",".popover",function(){return EMT.mixCard.hidePopover=!0,EMT.mixCard.closePopover()}),$(document).on("click",".mixCard",function(){var e;return e=$(this).data("id"),EMT.mixId=e,EMT.pageRouter.navigate("/mix/"+e+"/1",{trigger:!0,replace:!0})}),$(document).on("click",".popover ul.mix-tracks li:not(.more)",function(){var e,t;return e=$(this).closest(".popover").siblings(".mixCard").data("id"),EMT.mixId=e,t=$(this).index()+1,EMT.pageRouter.navigate("/mix/"+e+"/"+t,{trigger:!0,replace:!0})}),$(document).on("click",".popover ul.mix-tracks li.more",function(e){return e.stopPropagation(),$(this).remove(),$("ul.mix-tracks li.hide-after").removeClass("hide-after")}),$(document).on("click","#mix_stage ul.mix-tracks li",function(){return EMT.currentTrack=$(this).index(),EMT.controls.nextSong()});