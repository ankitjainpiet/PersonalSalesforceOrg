// We support IE 9 and above
// This check will detect IE versions below 9
if (window.attachEvent && !window.addEventListener) {
    alert("Oops, we don't support this browser. We recommend upgrading or switching to a newer browser.");
}
var communities = {
		
    config: {
        VIEW_PANEL : ".cViewPanel",
        HEADER_PANEL : ".cHeaderPanel",
        BODY_PANEL : ".cContentPanel",
        FOOTER_PANEL : ".cFooterPanel",
        BRAND_LOGO : ".cBrandingLogo",
        PROFILE_PANEL : ".cProfileCon"
    },

    qsToEventMap: {
        'searchQuery'  : 'e.selfService:showQuestionPost'
    },

    event: {
        TOGGLE_SIDEBAR : "selfService:toggleSidebar",
        CASE_CREATED: "selfService:caseCreated",
        ROUTE_CHANGE : "selfService:routeChange",
        CASE_HIGHLIGHT_RENDERED: "selfService:caseHighlightsRendered",
        TOGGLE_PROFILE: "selfService:profileMenuToggle",
	PROFILE_PAGE_TITLE_UPDATE: "forceCommunity:updateUserProfile"
    },
    
    routeType : null,

    siteState : {},

    defaultTitle: document.title,

    init: function(config){
        $(document).ready(function(){
            communities.initEvent();
            communities.viewPanel = $(communities.config.VIEW_PANEL);
        });
        this.siteState = config;
    },
    
    initEvent: function() {
        var that = this,
            body = $('body');
        $A.eventService.addHandler({event: that.event.CASE_CREATED, handler: that.afterCaseCreated});
        $A.eventService.addHandler({event: that.event.CASE_HIGHLIGHT_RENDERED, handler: that.showCaseCreateConfirmation});
        $A.eventService.addHandler({event: that.event.TOGGLE_PROFILE, handler: that.toggleProfileConClass});
        $A.eventService.addHandler({event: that.event.ROUTE_CHANGE, handler: that.routeChangeHandler});
        $A.eventService.addHandler({event: that.event.PROFILE_PAGE_TITLE_UPDATE, handler: that.updateProfilePageTitle});
        if (body) {
            body.bind('routeChangeSuccess', that.handleRouteChangeSuccess);
        }
        that.attachSwipeEvents();
        that.attachClickEvents();

    },

    routeChangeHandler: function(event) {
	 var routeType = event.getParam("routeType"),
            SEOEvt,
            title,
            description;
	this.routeType = routeType;
        if (routeType != 'article' && routeType != 'topic' && routeType != 'feeditem' && routeType != 'detail-005') {
            title = communities.defaultTitle;
            description = '';
        } else if (routeType === 'topic') {
            title = event.getParam('routeParams').topicName;
        }

        if (title) {
            SEOEvt = $A.get('e.siteforce:setSEOProperties');
            if (SEOEvt) {
                SEOEvt.setParams({
                                     title : title,
                                     meta : {description : description}
                                 });
                SEOEvt.fire();
            }
        }

        communities.scrollTop();
    },
    
    scrollTop : function() {
        $("html, body").animate({ scrollTop: 0 }, "fast");
    },
    
    attachSwipeEvents: function () {
        var self = this,
            container = $(self.config.VIEW_PANEL)[0];

        if (!container) {
            return;
        }
        if(!container.addEventListener) {
        	container.attachEvent('ontouchstart', function (e) {});
            container.attachEvent('ontouchmove', function (e) {});
            container.attachEvent('ontouchend', function (e) {});
        } else {
        	container.addEventListener('touchstart', function (e) {}, false);
            container.addEventListener('touchmove', function (e) {}, false);
            container.addEventListener('touchend', function (e) {}, false);
        }
    },

    attachClickEvents: function() {
        var logo = $(communities.config.BRAND_LOGO);
        logo.click(this.goHome);
    },

    toggleProfileConClass : function(event) {
        var isExpanded = event.getParam("isExpanded"),
            profilePanel = $(communities.config.PROFILE_PANEL);
        if (isExpanded) {
            profilePanel.addClass('active');
        } else {
            profilePanel.removeClass('active');
        }
    },

    // scrollToMyCases and scrollToAboutMe are used by custom code in our 192 template.
    // They are not used in our 194 template: this feature was removed.
    //
    scrollToMyCases : function() {
        this.scrollToElement('#myCasesCon');
    },
    
    scrollToAboutMe : function() {
        this.scrollToElement('#aboutMeCon');
    },

    scrollToElement : function(selector) {
        $('body, html').animate({
                                    scrollTop: Math.round($(selector).offset().top) + 'px'
                                }, 800, 'linear');
    },

    handleRouteChangeSuccess : function(event, params) {
        var routeType = params.routeType;
        if (routeType === 'detail-005') {
            //check that it has caseList or not
            if ($('.selfServiceMyCaseList').length < 1) {
                $('#content').addClass('noCasesAccess');
            } else {
            	$('#content').removeClass('noCasesAccess');
            }
        } else if (routeType === 'contactsupport' && $A.get('$Browser.isPhone')) {
            communities.scrollToElement('#content');
        }
    },
    
    goHome : function(event) {
        var navigateToHome = $A.get('e.force:navigateHome');
        if (navigateToHome) {
            navigateToHome.fire();
        }
    },
    
    afterCaseCreated: function(event) {
        var firstFired = event.getParam("firstFired");
        if (firstFired) {
            communities.showCaseConfirmation = true;
            communities.confirmationMessageTitle = event.getParam("confirmationMessageTitle");
            communities.confirmationMessageDescription = event.getParam("confirmationMessageDescription");
        }
    },
    
    showCaseCreateConfirmation: function(event) {
        if (communities.showCaseConfirmation) {
            $A.get('e.selfService:caseCreated').setParams({
                firstFired: false,
                confirmationMessageTitle: communities.confirmationMessageTitle,
                confirmationMessageDescription: communities.confirmationMessageDescription
            }).fire();
            communities.showCaseConfirmation = false;
        }
    },
    
    registerQueryStringProcessor: function(picassoSpa) {
        var that = this;
        for (k in that.qsToEventMap) {
            if (!picassoSpa.getQueryStringProcessor(k)) {
                picassoSpa.registerQueryStringProcessor(k, that.qsToEventMap[k]);
            }
        }
    },

    updateProfilePageTitle: function(event) {
		if(this.routeType != 'detail-005' && $('.profileView').length < 1){ 
			return true;
		}

		var profileDisplayName = event.getParam("userDisplayName");
		var SEOEvt = $A.get('e.siteforce:setSEOProperties');
		if (SEOEvt && profileDisplayName) {		    
			SEOEvt.setParams({
			         title : profileDisplayName
			});
			SEOEvt.fire();
		}
	 }
};
