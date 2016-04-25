/**
 * module for SPA functionality for Site.com pages
 */
var picassoSPA = (function() {

    // PRIVATE VARS/ FUNCTIONS
    ///////////////////////////////

    var currentRoute = {
        type: '',
        params: {},
        url: ''
    };

    var _qsToEventMap = {};

    /**
     * Checks to see if the url contains a query string key
     * Returns: true/false
     **/
    function hasQS(queryString, qsKey, keyValue) {
        if (queryString) {
            var hashes = queryString.split('&');
            for (var i = 0; i < hashes.length; i++) {
                var kv = hashes[i].split('=');
                if (kv[0] === qsKey) {
                    if (kv.length > 1) {
                        keyValue[kv[0]] = decodeURIComponent(kv[1]);
                    }
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * This just fires off query-string based events (for now).
     * TODO: separate this function into 3 (init, registration, and processing)
     *
     */
    function _fireQueryStringEvents(queryString) {
        // look for all registered query-strings
        for (var k in _qsToEventMap) {
            var keyValue = {};
            if (hasQS(queryString, k, keyValue)) {
                var event = _qsToEventMap[k];
                var evt = $A.get(event);
                if (evt) {
                    if (keyValue[k]) {
                        evt.setParams(keyValue);
                    }
                    evt.fire();
                }
            }
        }
    }


    /**
     * go through each route and bind it
     */
    function _initRouteMapping(spa) {

        for (var route in spa.routeMapping) {
            var routeId = spa.routeMapping[route]; // should be a key/value pair array of page/view properties

            (function(routeId) {
                // main main route
                spa.mapRoute(spa.SPA_PATH_PREFIX, route, routeId);
            })(routeId);
        }

        // define our own error view if the user didn't supply one
        if (!spa.routeMapping[spa.ERROR_ROUTE_URL]) {
            spa.Router.on(spa.SPA_PATH_PREFIX + spa.ERROR_ROUTE_URL, function() {
                spa.clearLoading();

                spa.setCurrentRoute(spa.SPA_PATH_PREFIX + spa.ERROR_ROUTE_URL, '', {});

                var target = spa.DEFAULT_CENTER_STAGE;
                var errorText = spa.DEFAULT_ERROR_TEXT.replace('%s', spa.SPA_PATH_PREFIX + '/');
                $(target).html('<div class="spaError">' + errorText + '</div>');

                // add a few styles for the link and div
                $('.spaError').css('padding', '10px');
                $('.spaErrorLink').css('padding', '10px 0').css('display', 'block');
            });
        }
    }

    function _setCurrentRoute(url, type, params) {
        currentRoute.url = url;
        currentRoute.type = type;
        currentRoute.params = params;
    }

    /**
     * Build a url from a route by index & replace of parameters.
     * @param {String} eventRoute The index of the route
     * @param {Object} tokens (optional) Key-value pair of route tokens to replace
     * @return {String} The url corresponding to the route
     */
    function _buildRoute(spa, eventRoute, tokens) {
        var url;

        if (spa.eventToRouteMapping) {
            url = spa.eventToRouteMapping[eventRoute];
            if (url) {
                if (tokens) {
                    $.each(tokens, function(key, value) {
                        url = url.replace(':' + key, encodeURIComponent(value));
                    });
                }
                }
            }
        return url;
    }


    /**
     * called during init to cache query strings into a map, for later usage
     * @param qs the original raw query string to parse & store
     */
    function _initQueryStringCache(spa, qs) {
        if (qs) {
            var kvs = qs.split('&');
            for (var i = 0; i < kvs.length; i++) {
                var kv = kvs[i].split('=');
                if (kv.length > 1) {
                    spa.queryStringCache[kv[0]] = kv[1];
                }
            }
        }
    }


    return {

        // PUBLIC VARIABLES
        ///////////////////////////////

        // path prefix used for the current site, includes page-name
        SPA_PATH_PREFIX: "/",
        // login page url
        LOGIN_PAGE_URL: "/",
        // default center stage locator
        DEFAULT_CENTER_STAGE: "#content",
        // default error route URL
        ERROR_ROUTE_URL: '/error',
        // default error text - overwritten by server
        DEFAULT_ERROR_TEXT: '',
        // current user name, empty if guest user
        USER_NAME: "",
        // current aura session token
        AURA_TOKEN: "",
        // stores the aura mode the SPA was loaded with
        AURA_MODE: "",
        // which s1 event names require authentication before being processed
        AUTH_ROUTE_TYPES: {
            'list-Case': true,
            'detail-500': true
        },
        // stores a special route cache state indicating a 'dirty' route which should avoid cache & force re-fetch (bypassing proxy cache)
        ROUTE_CACHE_DIRTY: 42,

        // stores mapping of Events - to - Routes
        eventToRouteMapping: {
            'content-doc': '/sfc/servlet.shepherd/document/download/:recordId?operationContext=CHATTER',
            'attachment': '/servlet/servlet.FileDownload?file=:recordId'
        },
        // stores mapping of route urls to route ids
        routeMapping: {},
        // stores routes to events
        routeToEventMap: {},
        // routeloaded state - id to state
        routeCache: {},
        // stores a snapshot of the query strings this page was loaded with
        queryStringCache: {},

        getCurrentRoute: function() {
            return currentRoute;
        },

        /**
         * returns the currently active path (without path prefix) , eg. / or /categoryHome/cats
         */
        getActiveRouteUrl: function() {
            var activeUrl = picassoSPA.Router.getPath().replace(picassoSPA.SPA_PATH_PREFIX, '');
            return activeUrl == "" ? "/" : activeUrl;
        },

        setCurrentRoute: _setCurrentRoute,

        Router: new Router(),

        // PUBLIC METHODS
        ///////////////////////////////
        /**
         * kicks things off for the SPA state
         *  - initiates a route change if needed after initial page load
         */
        init: function() {
            var self = this;
            var qs = window.location.search.substring(1).replace(/\+/g, ' ');

            _initQueryStringCache(this, qs);

            var modeqs = {};
            if (hasQS(qs, "aura.mode", modeqs)) {
                this.AURA_MODE = modeqs["aura.mode"];
            }

            this.Router.configure({
                'notfound': this.handleRouteMiss,
                strict: false,
                html5history: true,
                'before': function(route, other) {
                    // TODO: nasty loading stuff, this needs to be based on a required view,
                    // if not then falls back to some default provided by the template
                    self.showLoading();
                }
            });

            // bind known routes
            _initRouteMapping(this);

            var path = window.location.pathname;

            // first load auth status, then kick off route processing
            this.queryAuth(function() {
                // initializing the router with a path makes the home view load in all browsers. Yay!
                self.Router.init(path);

                // scan links on the page & convert them
                self.initPageLinks();
                
                // start polling session state
                self.startPollingAuthStatus();
            });

            // register query string processors
            // TODO: THIS SHOULD BE DONE BY THE SELF-SERVICE CODE
            if (typeof selfService !== 'undefined') {
                selfService.registerQueryStringProcessor(this);
            }
            if (window.communities) {
                communities.registerQueryStringProcessor(this);
            }
            if (window.salesforceIdentity) {
                salesforceIdentity.registerQueryStringProcessor(this);
            }

            setTimeout(function() {
                _fireQueryStringEvents(qs);

                // fix the cache - preloaded stuff may be put there, but that preloaded stuff may not want to be cached
                $.each(self.routeCache, function(url, val) {
                    var metadata = self.routeMetadata[url];
                    if (metadata && parseInt(metadata["cache_minutes"]) == 0) {
                        self.routeCache[url] = null;
                    }
                });
            }, 0);
        },

        /**
         * perform a redirect to the login page
         * @param {String} startRouteUrl : if not provided, uses the currently active Router.getPath()
         */
        fireLoginEvent: function(startRouteUrl) {
            navigateToLogin = $A.get('e.selfService:doLogin');
            if (navigateToLogin) {
                navigateToLogin.setParams({
                    startUrl: startRouteUrl ? startRouteUrl : this.Router.getPath()
                });
                navigateToLogin.fire();
            }
        },

        /**
         * @param {String} routeType is the "s1 event name" associated with that route, e.g. "list-Case" or "detail-005"
         * @return {Boolean} false (+fire login event) if we are failing authentication requirements for the given route type
         */
        checkAuth: function(routeType) {
            if (this.AUTH_ROUTE_TYPES[routeType] && !this.USER_NAME) {
                // this route requires authentication and we don't consider ourselves logged in
                this.fireLoginEvent();
                return false;
            }
            return true;
        },

        /**
         * makes an ajax call to determine auth status; updates .USER_NAME local state
         * @param {Function} onFinish if provided, is a callback once auth status has been determined
         */
        queryAuth: function(onFinish) {
            var self = this;
            var successCB = function(res) {
                // cache the user name & session token
                self.USER_NAME = res.name;
                self.AURA_TOKEN = res.csrf;

                // ensure subsequent aura calls carry this session token
                $A.clientService.resetToken(picassoSPA.AURA_TOKEN);

                // modify the preloaded views' cache keys (including parameter list, which server doesn't provider)  so we get a hit, and avoid duplicate renders
                var cacheKeyParams = {};
                // first add any inherited query string params
                $.each(self.queryStringCache, function(k,v) {
                    cacheKeyParams[k] = v;
                });

                if (res.csrf) {
                        cacheKeyParams["aura.token"] = res.csrf;
                }
                var cacheKeySuffix = JSON.stringify(cacheKeyParams);
                $.each(self.routeCache, function(url, val) {
                        self.routeCache[url+cacheKeySuffix] = val;
                });

                if (onFinish) {
                    onFinish();
                }
            };

            var failCB = function(res) {
                if (console && console.log) {
                    console.log("Error during user check! " + res);
                }

                // if there was an error, assume not logged in
                self.USER_NAME = "";

                // if callback is requested issue it now, which unblocks rendering
                if (onFinish) {
                    onFinish();
                }
            };
            picassoRuntime.RuntimeService.call("GetSessionInfo", [], successCB, failCB);
        },
        
        /**
         * sets up a timer to query the session information
         */
        startPollingAuthStatus: function() {
            var self = this;
            var pollingIntervalSeconds = 30;

            if (!self.USER_NAME) {
                // this is an anonymous session, no need to poll for authentication timeout
                return;
            }
            
            // poll the session
            setTimeout(function() {
                picassoRuntime.RuntimeService.call("GetSessionInfo", [], function(res) {
                    if (!res.name || !res.csrf) {
                        // session time out detected
                        picassoSPA.fireLoginEvent();
                    } else {
                        // session still valid / present, poll again
                        self.startPollingAuthStatus();
                    }
                });
            }, pollingIntervalSeconds*1000);
        },

        handleRouteMiss: function(e) {
            picassoSPA.Router.dispatch('on', picassoSPA.SPA_PATH_PREFIX + picassoSPA.ERROR_ROUTE_URL);
        },

        /**
         * populated by server - holds all the route state needed for client side maps
         * incoming map is of the form {url  : properties} where properties can be  {id,event}
         */
        setRoutes: function(routeMap) {
            var self = this;
            self.routeMetadata = routeMap;
            $.each(self.routeMetadata, function(routeUrl, routeProps) {
                self.routeMapping[routeUrl] = routeProps.id;
                if (routeProps.event) {
                    if (routeProps.event === 'feeditem') {
                        routeProps.event = 'feeditem-question';
                    }
                    self.eventToRouteMapping[routeProps.event] = routeUrl;
                    self.routeToEventMap[routeUrl] = routeProps.event;
                } else {
                    self.routeToEventMap[routeUrl] = '';
                }
            });
        },

        /**
         * helper to append optional query strings to a URL
         * @param {map} options A map of optional parameters to be passed along with the route arguments
         * @return the URL, modified  with query strings provided by 'options'
         */
        addURLParams: function(url, options) {
            var segments = [];

            if (options) {
                $.each(options, function(key, value) {
                    segments.push(key + "=" + encodeURIComponent(value));
                });
                if (segments.length > 0) {
                    url += url.indexOf('?') > -1 ? '&' : '?';
                    url += segments.join('&');
                }
            }
            return url;
        },

        /**
         * Open a new web page.
         * @param {String} url The url of the web page
         * @param {map} options A map of optional query strings to use with the URL
         */
        openURL: function(url, options) {
            window.open(this.addURLParams(url, options));
        },

        /**
         * Navigate to a URL - if it starts with a slash, it is presumed to be a route, so we
         * invoke the routing system, otherwise we just replace the current window location
         * @param {String} url The url of the route
         * @param {map} options A map of optional parameters to be passed along with the route arguments
         */
        navigateToURL: function(url, options) {
            var newPath;
            var startIndex;
            var hostSubstring = window.location.host + this.SPA_PATH_PREFIX;

            function shouldRouteUrl(url, hostString) {
                var index;

                // action-link-redirect (ActionLinkRedirectServlet) should not be routed
                if(url.indexOf('/action-link-redirect') !== -1) {
                    return false;
                }

                // root relative URLs are assumed to be within the SPA and are thus routed
                if (url.charAt(0) === '/') {
                    return true;
                } 

                // if the URL contains the same host and exact same path prefix, then route it (because someone passed an absolute URL :( )
                // this check used to be non-exact, but is being hardened for W-2538363
                index = url.indexOf(hostString);
                if (index > -1 && (index + hostString.length === url.length || url.charAt(index + hostString.length) === '/')) {
                    return true;
                }
            }

            if (url && typeof(url) === 'string' && url.length > 0) {
                if (shouldRouteUrl(url, hostSubstring)) {
                    // prior to route change, store the extra params
                    this.extraRouteParams = options;

                    // trigger the change
                    if (url.charAt(0) === '/') {
                        newPath = this.SPA_PATH_PREFIX + url;
                    } else {
                        startIndex = url.indexOf(hostSubstring) + hostSubstring.length - this.SPA_PATH_PREFIX.length;
                        newPath = url.substring(startIndex);
                    }

                    this.Router.setRoute(newPath);
                } else {
                    var self = this;
                    var params = $.extend({}, self.queryStringCache, options);

                    setTimeout(function() {
                        window.location.href = self.addURLParams(url, params);
                    }, 100);
                }
            }
        },

        /**
         * Navigate to login.
         * @param {String} startUrl The url to return to after login
         */
        navigateToLogin: function(startUrl) {
            if (!startUrl) {
                startUrl = picassoSPA.Router.getPath();
                }
            startUrl = this.addURLParams(startUrl, {'t': new Date().getTime()});
            
            // double re-encode already encoded characters
            startUrl = encodeURIComponent(startUrl).replace(/%25/g, '%2525');
            
            window.location.href = this.LOGIN_PAGE_URL + '?startURL=' + startUrl;
        },

        /**
         * Navigate to logout.
         * @param {String} url The logout url
         * @param {Boolean} internalUser Is this an internal Salesforce user
         */
        navigateToLogout: function(url) {
            window.location.href = url;
        },

        /**
         * Navigation to a route by index & replace of parameters.
         * @param {String} eventRoute The index of the route
         * @param {Object} tokens (optional) Key-value pair of route tokens to replace
         * @param {Object} options (optional) Key-value pair of optional parameters to add
         * @return {Boolean} True if the route has been found
         */
        navigateToEventRoute: function(eventRoute, tokens, options) {
            var found = false;
            var url = _buildRoute(this, eventRoute, tokens);
            if (url) {
                this.navigateToURL(url, options);
                found = true;
            }
            return found;
        },

        /**
         * Navigate to a file by opening it in a new tab
         * @param {String} prefix The prefix for the community without /s/
         * @param {String} url The url for the file
         */
        navigateToFile: function(prefix, url) {
        	var newPath;

        	if (url && typeof(url) === 'string' && url.length > 0) {
        		if (url.charAt(0) === '/') {
        			newPath = prefix + url;
        		} else {
        			newPath = url;
        		}
        		window.open(newPath, "_blank");
        	}
        },

        /**
         * Open a url to a route by index & replace of parameters.
         * @param {String} prefix The prefix of the route
         * @param {String} eventRoute The index of the route
         * @param {Object} tokens (optional) Key-value pair of route tokens to replace
         * @param {Object} options (optional) Key-value pair of optional parameters to add
         * @return {Boolean} True if the route has been found
         */
        openEventRoute: function(prefix, eventRoute, tokens, options) {
            var found = false;
            var url = _buildRoute(this, eventRoute, tokens);
            if (url) {
                this.openURL(prefix + url, options);
                found = true;
            }
            return found;
        },

        /**
         * destroy all aura component in a given container
         * @param {Object} container
         */

        destroyComponentsInContainer: function(container) {
            var components = $('[id^=aura-c-]', container);
            var cmpLen = components.length;
            var cmpIndex;
            var auraRoot;
            var cmp;

            if (cmpLen) {
                // destroy all components in current view before injecting new view
                auraRoot = $A.getRoot();
                for (cmpIndex = 0; cmpIndex < cmpLen; cmpIndex++) {
                    cmp = auraRoot.find(components[cmpIndex].id);
                    if (cmp) {
                        cmp.destroy();
                    }
                }
            }
        },

        /**
         * helper to take a route id and return the raw route url e.g. /routename/:param
         */
        getRouteUrlFromId: function(id) {
          for (var routeUrl in this.routeMapping) {
            if (id === this.routeMapping[routeUrl]) {
                return routeUrl;
            }
          }
          return null;
        },

        /**
         * call back on a successful return from an ajax render call
         * @param {Object} res is the result returned from server
         */
        onRenderSuccess: function(routeId, routeUrl, res, cache_key) {
            var routeBaseUrl = picassoSPA.getRouteUrlFromId(routeId);
            var cache_duration = routeBaseUrl ? picassoSPA.routeMetadata[routeBaseUrl]["cache_minutes"] : 1;

            for (var i = 0; i < res.RenderData.length; ++i) {
                var render = res.RenderData[i];
                var target = render.RenderInfo.RenderTarget ? $(render.RenderInfo.RenderTarget) : $(picassoSPA.DEFAULT_CENTER_STAGE);

                picassoSPA.destroyComponentsInContainer(target);

                // Insert HTML
                target.html(render.Result.HTML);

                if (!picassoSPA.routeCache[cache_key]) {
                    // load CSS Files
                    for (var csi = 0; csi < render.Result.CSS_FILES.length; ++csi) {
                        $("<link/>", {
                            rel: "stylesheet",
                            type: "text/css",
                            href: render.Result.CSS_FILES[csi]
                        }).appendTo("head");
                    }

                    // load JS files
                    for (var jsfi = 0; jsfi < render.Result.JS_FILES.length; ++jsfi) {
                        $.getScript(render.Result.JS_FILES[jsfi]);
                    }

                    if (parseInt(cache_duration) > 0) {
                        // mark this state as been loaded - never load it again
                        picassoSPA.routeCache[cache_key] = res;
                    }
                }

                // execute inline JS
                for (var jsi = 0; jsi < render.Result.JS.length; ++jsi) {
                    eval(render.Result.JS[jsi]);
                }
            }

            picassoSPA.clearLoading();

            // TODO: render is used out of scope
            picassoSPA.onRoutePost(render.RenderInfo.RouteType);
        },

        /**
         * call back on a failed return from an ajax render call
         */
        onRenderFail: function(res) {
            picassoSPA.clearLoading();
            if (res && res.error === "DISCONNECTED") {
                // not logged in error! update our local state
                picassoSPA.USER_NAME = "";
                // go to login
                picassoSPA.fireLoginEvent();
            } else {
                // generic error
                picassoSPA.handleRouteMiss();
            }
        },

        /**
         * called to invalidate a route URL in the javascript cache
         * @param route url is the fully qualified route url with arguments (e.g. /list/id2492). if null, uses the currently active route url
         */
        invalidateRouteCache: function(routeUrl) {
            if (!routeUrl) {
                routeUrl = this.getActiveRouteUrl();
            }
            this.routeCache[routeUrl] = this.ROUTE_CACHE_DIRTY;
        },

        /**
         * called right before a route view is requested (from server or cache)
         */
        onRoutePre: function(routeType, route, params) {
            var routeChange, navigateToLogin;

            if (!this.checkAuth(routeType)) {
                // don't process the route
                return false;
            }

            //EPT Instrumentation
            $A.metricsService.transactionStart("Communities", "route");

            routeChange = $A.get("e.selfService:routeChange");
            // if no one is listening to the event this returns null
            if (routeChange) {
                routeChange.setParams({
                    route: route,
                    routeType: routeType,
                    routeParams: params
                }).fire();
            }
            // process the route as per normal
            return true;
        },

        countView: function(view_udd_id) {
            if (this.lastView && this.lastView == view_udd_id) {
                // ignore duplicate triggers (needs to be addressed)
                return;
            }
            this.lastView = view_udd_id;

            if (!picassoSPA.USER_NAME) {
                try {
                    NetworkTracking.logPageView(view_udd_id);
                } catch (x) {
                    // We don't want problems with tracking code to leak onto the page
                }
            }
        },

        /**
         * called right after a route view has been (successfully) retrieved &
         * processed (from server or cache)
         */
        onRoutePost: function(routeType) {
            var current_route_obj = this.getCurrentRoute();
            var current_route_url_key = current_route_obj.url.replace(picassoSPA.SPA_PATH_PREFIX, '');
            var current_route_metadata = this.routeMetadata[current_route_url_key];
            var current_view_uddid = current_route_metadata["view_uddid"];
            var previewId = picassoSPA.queryStringCache["viewid"];
            if (previewId) {
                // one time use only (after iframe load)
                delete picassoSPA.queryStringCache["viewid"];
            }

            this.countView(current_view_uddid);
            var body = $('body');
            if (body) {
                body.trigger('routeChangeSuccess', {
                    routeType: routeType,
                    routeId: current_route_metadata.id,
                    routeUrl: current_route_url_key,
                    routeParams: current_route_obj.params,
                    // pass along the view id (affects live mode only, if the frame was loaded with it, it will be used)
                    viewId: previewId
                });
            }

            //EPT Instrumentation
            var context = {
              route_url_key : current_route_url_key,
              routeType : routeType ? routeType : ""
            };
            $A.metricsService.transactionEnd("Communities", "route", { context : context });
        },


        /**
         * helper to show the preloader animation.
         */
        showLoading: function() {
            $A.getEvt('force:toggleModalSpinner').setParams({isVisible: true}).fire();
        },

        /**
         * helper to hide the preloader animation.
         */
        clearLoading: function() {
            $A.getEvt('force:toggleModalSpinner').setParams({isVisible: false}).fire();
        },

        /**
         * helper to map an individual route
         */
        mapRoute: function(routeBaseUrl, route, routeId) {
            var self = this;

            // if this route ends with a slash lets remove it
            if (/\/$/.test(routeBaseUrl)) {
                routeBaseUrl = routeBaseUrl.substring(0, routeBaseUrl.length - 1);
            }

            this.Router.on(routeBaseUrl + route, function() {
                var routeType;
                var routeChange;
                var navigateToLogin;
                var params = {};
                var i;
                var j;
                var index;
                var segments;
                var parameters;

                routeType = self.routeToEventMap[route];

                // carry over the original SPA query strings with each ajax call
                // we pack this into 'params' first, thereby allowing the route-specific arguments to override in case of a name conflict
                $.each(self.queryStringCache, function(k,v) {
                    params[k] = v;
                });

                // extract parameters (director doesn't do this for us)
                if (arguments.length > 0) {
                    segments = route.split('/');
                    parameters = [];

                    for (j = 0; j < segments.length; ++j) {
                        index = segments[j].indexOf(':');
                        if (index >= 0) {
                            parameters.push(segments[j].substring(1));
                        }
                    }

                    for (i = 0; i < arguments.length; ++i) {
                        // extract parameters from route
                        params[parameters[i]] = decodeURIComponent(arguments[i]);
                    }
                }

                if (self.extraRouteParams) {
                    $.extend(params, self.extraRouteParams);
                    self.extraRouteParams = null;
                }

                if (!self.onRoutePre(routeType, route, params)) {
                    // pre-route event was handled
                    return;
                }

                if (self.AURA_MODE) {
                    params["aura.mode"] = self.AURA_MODE;
                }

                if (self.AURA_TOKEN) {
                    params["aura.token"] = self.AURA_TOKEN;
                }

                if (self.AUTH_ROUTE_TYPES[routeType]) {
                    // give the request a hint that we're expecting an existing user session
                    params["picasso_auth"] = true;
                }

                // store the current route attributes for clients to query
                self.setCurrentRoute(routeBaseUrl + route, routeType, params);

                // this retrieves the actual (parameterized) url currently being served
                var current_route_url = self.getActiveRouteUrl();

                // calculate a client cache key based on path + parameters
                var cache_key = current_route_url + JSON.stringify(params);

                var cached_state = self.routeCache[cache_key];

                // disable the local js cache if:
                // cache entry has been invalidated OR a user sesison exists (and this is not the home view - which is preloaded into the cache)
                var cacheDisabled = cached_state === self.ROUTE_CACHE_DIRTY ||
                  (self.USER_NAME && current_route_url != "/");

                if (cacheDisabled) {
                    // this cached view has been invalidated OR an authenticated session exists

                    // don't re-render
                    cached_state = null;
                    // bypass proxy cache to force refetch
                    params["picasso_refetch"] = Date.now();
                }

                if (cached_state) {
                    // this view has been preloaded, no need to call runtime service
                    self.onRenderSuccess(routeId, current_route_url, cached_state, cache_key);
                } else {
                    // call out to render
                    picassoRuntime.RuntimeService.renderComponent(
                        routeId,
                        params,
                        function(res) {
                            self.onRenderSuccess(routeId, current_route_url, res, cache_key);
                        },
                        self.onRenderFail
                    );
                }
            });
        },

        initPageLinks: function() {
            // use jquery to tell <a> tags to instead use the routing system
            // sadly using old jquery so using 'delegate' instead of 'on'
            var self = this;
            $(document).delegate("a", "click", function(event) {
                var href = $(this).attr("href");
                // if the requested URL is not a root-relative URL (and therefore possibly a route)
                // then let the browser handle it as per usual
                if (!href || !self.Router.match(href)) {
                    return true;
                }

                // this prevents browser from following the a-tag
                event.preventDefault();

                self.Router.setRoute(href);
            });
        },

        /**
         * Register a processor to handle query string parameters
         * This can be an Aura event to fire, or a        function to call
         */
        registerQueryStringProcessor: function(token, action) {
            _qsToEventMap[token] = action;
        },

        /**
         * Return a processor for a given token
         */
        getQueryStringProcessor: function(token) {
            return _qsToEventMap[token];
        }
    };
})();
