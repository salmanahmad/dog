// Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
// All rights reserved.

// Permission is granted for use, copying, modification, distribution,
// and distribution of modified versions of this work as long as the
// above copyright notice is included.


/*

TODO - Add support for displays track references
TODO - Allow for named templates and cascading template selection
TODO - Allow developers to change the template used with callback

TODO - Javascript API to authenticate and to check the authentication status
TODO - Allow error handling callbacks for the core API functions

TODO - Pass in the context to the delegate callbacks
TODO - Move from delegates to subscribe model
TODO - Move from subscribe model to a promise model with chained callbacks

TODO - Support other templating libraries
TODO - jsonp support?

*/

$.fn.serializeObject = function() {
  var o = {};
  var a = this.serializeArray();
  $.each(a, function() {
    if (o[this.name]) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || '');
    } else {
      o[this.name] = this.value || '';
    }
  });
  return o;
};

$.fn.serializeAnything = function() {
  var hash = {};
  var els = $(this).find(':input').get();
  
  $.each(els, function() {
    if (this.name && !this.disabled && (this.checked || /select|textarea/i.test(this.nodeName) || /text|hidden|password/i.test(this.type))) {
      var val = $(this).val();
      hash[this.name] = val;
    }
  });
  
  return hash;
};

(function(scope) {
  
  var dog = {};
  var config = {};
  var state = {};
  var routing = [];
  var initialized = false;
  
  // TODO: Add this back in...
  //var streamClient = new Faye.Client('/dog/stream');
  
  var didStartLoadingCallback = function() {};
  var didEndLoadingCallback = function() {};
  
  var willRenderDataCallback = function(data, context, request) { return data };
  var didRenderDataCallback = function(data, context, request) { };
  
  var didLoginCallback = function() {};
  var didLogoutCallback = function() {};
  var didChangeAccountStatusCallback = function() {};
  
  var didLoadRootCallback = function() {};
  
  dog.areEqual = function(a, b) {
    if(b == null) {
      return false;
    }
  
    if(typeof(b) != 'object') {
      return false;
    }
  
    var p;
    for(p in a) {
      if(typeof(b[p])=='undefined') {
        return false;
      }
    }

    for(p in a) {
      if (a[p]) {
        switch(typeof(a[p])) {
        case 'object':
          if (!a[p].equals(b[p])) { 
            return false; 
          }
        
          break;
        case 'function':
          if (typeof(b[p])=='undefined' || (p != 'equals' && a[p].toString() != b[p].toString())) {
            return false;
          }
        
          break;
        default:
          if (a[p] != b[p]) { 
            return false; 
          }
        }
      } else {
        if (b[p]) {
          return false;
        }
      }
    }

    for(p in b) {
      if(typeof(a[p])=='undefined') {
        return false;
      }
    }

    return true;
  }
  
  // TODO - improve this a bit
  dog.queryStringParam = function(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
        if (decodeURIComponent(pair[0]) == variable) {
            return decodeURIComponent(pair[1]);
        }
    }
    
    return false
  }
  
  dog.route = function(pattern, callback) {
    routing.push({
      pattern: pattern,
      callback: callback
    })
  }
  
  dog.subscribe = function(endpoint, callback) {
    streamClient.subscribe(endpoint, callback)
  }
  
  dog.performRouting = function() {
    var request = window.location.hash
    request = request.substring(1)
    
    for(var i in routing) {
      var pattern = routing[i].pattern
      var callback = routing[i].callback
      
      if(!(pattern instanceof RegExp)) {
        pattern = new RegExp("^" + pattern + "$")
      }
      
      if(pattern.test(request)) {
        var args = pattern.exec(request)
        args.shift()
        callback.apply(window, args)
        return true
      }
    }
    
    return false
  }
  
  dog.reloadState = function() {
    state = {}
    var path = window.location.hash

    if (path && /#(\/.+\/.+)+/.test(path)) {
      path = path.split("/")
      path = $.grep(path, function(a) {
        if (a != "") {
          return a
        }
      })

      path.shift()

      for(var i = 0; i < path.length; i++) {
        var viewport = path[i]
        i++
        var frameId = path[i]
        
        state[viewport] = frameId
        
        var context = $("*[data-dog-viewport='" + viewport + "']:first")
        if($(context).size() > 0) {
          dog.renderFrame(frameId, context)
        }
      }
      
      return true
    } else {
      return false
    }
  }
  
  dog.pathForState = function() {
    var path = ""
    for(var i in state) {
      path += "/" + i + "/" + state[i]
    }
    
    return path;
  }
  
  dog.initialize = function(options) {
    if(!initialized) {
      initialized = true;
      var defaultOptions = {
        'performRouting': true,
        'reloadState': true,
        'autoRun': true,
        'autoPermalink':true,
        'templates':'#templates',
        'rootSelector':'root',
        'baseUrl':'/dog',
        'logRenderedData': true
      }
      
      options = options || defaultOptions
      config = $.extend({}, defaultOptions, options);
    }
  }
  
  dog.didStartLoading = function(callback) {
    didStartLoadingCallback = function() {
      if(callback) {
        callback();
      }
    }
  }
  
  dog.didEndLoading = function(callback) {
    didEndLoadingCallback = function() {
      if(callback) {
        callback();
      }
    }
  }
  
  dog.willRenderData = function(callback) {
    willRenderDataCallback = function(data, context, request) {
      if(callback) {
        return callback(data, context, request)
      } else {
        return data
      }
    }
  }
  
  dog.didRenderData = function(callback) {
    didRenderDataCallback = function(data, context, request) {
      if(callback) {
        callback(data, context, request);
      }
    }
  }
  
  dog.didLogin = function(callback) {
    didLoginCallback = function() {
      if(callback) {
        callback()
      }
    }
  }
  
  dog.didLogout = function(callback) {
    didLogoutCallback = function() {
      if(callback) {
        callback()
      }
    }
  }
  
  dog.didAccountStatusChange = function(callback) {
    didChangeAccountStatusCallback = function() {
      if(callback) {
        callback()
      }
    }
  }
  
  dog.didLoadRoot = function(callback) {
    didLoadRootCallback = function() {
      if(callback) {
        callback()
      }
    }
  }
  
  dog.renderTemplate = function(data, context) {
    if(!context) {
      context = $("*[data-dog-viewport=root]:first")
    }

    if(config.logRenderedData) {
      console.log(data)
    }

    var originalData = data
    var originalContext = context

    var frames = [data.frame]
    if(data.spawns) {
      for(var i in data.spawns) {
        frames.push(data.spawns[i])
      }
    }
    
    for(var i in frames) {
      var data = frames[i]
      var selector = "";

      if (originalData.frame._id == data._id) {
        context = originalContext
      } else {
        context = $(originalContext).data("dog-spawn-viewport");
        context = $("*[data-dog-viewport='" + context + "']:first")
      }

      if($(context).size() == 0) {
        continue;
      }

      //if(data.package_name != "") {
      //  selector = data.package_name + ".";
      //}

      if(data.symbol_name.indexOf("@root") !== -1) {
        data.symbol_name = config.rootSelector;
      }

      selector = data.symbol_name;

      for(var i in data.listens) {
        var listen = data.listens[i];
        data.listens[i] = {
          "frame_id":data._id,
          "name":i,
          "listen":listen
        }
      }

      selector = selector.replace(/:/g,'-colon-');
      selector = selector.replace(/\./g,'-dot-');

      console.log(selector);

      if(selector.indexOf("@") == "-1" && $("#" + selector).length > 0) {

        var html = $("#" + selector + "[type='text/x-dog-template']").html()
        var source = "<div id='dog-" + data._id + "'>" + html + "</div>";
        var template = Handlebars.compile(source);

        data = willRenderDataCallback(data, context, originalData)
        html = template(data);

        if($(context).data("dog-update-strategy") == "replace") {
          $(context).html(html);
        } else if ($(context).data("dog-update-strategy") == "append") {
          $(context).append(html);
        } else {
          $(context).html(html);
        }
        
        state[$(context).data("dog-viewport")] = data._id
        
        didRenderDataCallback(data, context, originalData)
      }
    }
    
    if(config.autoPermalink) {
      window.location.hash = dog.pathForState()
    }
  }
  
  dog.accountStatusCached = {
    authenticated: false,
    email: null,
    name: null
  }
  
  dog.accountStatus = function() {
    var defer = new $.Deferred()
    var request = dog.request("GET", config.baseUrl + "/account/status")
    
    request.done( function(data) {
      defer.resolve(data["account_status"])
    }).fail(defer.reject).progress(defer.notify);
    
    return defer
  }
  
  dog.createAccount = function(email, password, confirm) {
    // TODO - Figure this out as well...
  }
  
  dog.login = function(email, password) {
    var request = dog.request("GET", config.baseUrl + "/account/login")
    // TODO - Finish this up...
    request.done(function(data) {
      didLoginCallback();
    })
    
    return request
  }
  
  dog.logout = function() {
    var request = dog.request("GET", config.baseUrl + "/account/logout")
    
    request.done(function(data) {
      didLogoutCallback();
    })
    
    return request
  }
  
  dog.facebookLogin = function(useNewWindow, redirectUri) {
    var location = config.baseUrl + "/account/facebook/login"
    
    if(!!redirectUri) {
      location += ("?redirect_uri=" + redirectUri)
    }
    
    if(useNewWindow) {
      window.open(location)
    } else {
      window.location = location
    }
  }
  
  dog.loadFrame = function(frame) {
    var request = dog.request("GET", dog.frameUrl(frame))
    return request
  }
  
  dog.callListen = function(action, data) {
    var request = dog.request("POST", action, data)
    return request
  }
  
  dog.callRootListen = function(listen, data) {
    var action = dog.listenUrl("root", listen);
    return dog.callListen(action, data);
  }
  
  dog.renderFrame = function(frame, context) {
    var request = dog.request("GET", dog.frameUrl(frame))
    didStartLoadingCallback();
    
    request.success(function(data) {
      dog.renderTemplate(data, context);
    });
    
    request.complete(function() {
      didEndLoadingCallback();
    });
    
    return request
  }
  
  dog.renderRootListen = function(listen, data, context) {
    var action = dog.listenUrl("root", listen);
    return dog.renderListen(action, data, context);
  }
  
  dog.renderListen = function(action, data, context) {
    var request = dog.request("POST", action, data)
    
    didStartLoadingCallback();
    
    request.done(function(data) {
      dog.renderTemplate(data, context);
    });
    
    request.always(function() {
      didEndLoadingCallback();
    })
    
    return request
  }
  
  dog.listenUrl = function(frame, name) {
    return dog.frameUrl(frame) + "/" + name;
  }
  
  dog.frameUrl = function(frame) {
    return config.baseUrl + "/frame/" + frame
  }
  
  dog.request = function(type, url, data) {
    var request = {
      type: type,
      url: url,
      contentType: "application/json"
    }
    
    if(!!data) {
      request.data = JSON.stringify(data)
    }
    
    request = $.ajax(request)
    
    request.done(function(data) {
      if(!!data["account_status"]) {
        if(!dog.areEqual(dog.accountStatusCached, data["account_status"])) {
          didChangeAccountStatusCallback()
        }
        
        dog.accountStatusCached = data["account_status"]
      }
    })
    
    request.fail(function() {})
    
    request.always(function() {})
    
    return request
  }
  
  dog.run = function() {
    $(function() {
      var templates = $("[type='text/x-dog-template']");

      for (var i = 0; i < templates.length; i++) {
        var template = templates[i];

        oldTemplate = template;
        template = $(template).clone()[0];

        var id = $(template).attr("id");
        id = id.replace(/:/g,'-colon-');
        id = id.replace(/\./g,'-dot-');

        $(template).attr("id", id);

        if($("#" + id).length == 0) {
          $("head").append(template);
        }
      }


      

      dog.initialize();
      
      if(config.performRouting) {
        if(dog.performRouting()) {
          return
        }
      }
      
      if(config.reloadState) {
        if(dog.reloadState()) {
          return
        }
      }
      
      if(config.autoRun) {
        dog.renderFrame("root")
        didLoadRootCallback();
      }
    })
  }
  
  $(".dog-form").live("submit", function() {
    var context = $(this).parents("*[data-dog-viewport]:first");
    dog.renderListen($(this).attr("action"), $(this).serializeObject(), context);
    return false;
  })
  
  $(".dog-link").live("click", function() {
    var context = $(this).parents("*[data-dog-viewport]:first");
    var data = $(this).serializeAnything()
    
    dog.renderListen($(this).attr("href"), data, context);
    return false;
  });

  Handlebars.registerHelper('inspect', function(value, options) {
    return JSON.stringify(value);
  });

  Handlebars.registerHelper('listenLink', function(listen, options) {
    var url = dog.listenUrl(listen.frame_id, listen.name);
    var ret = "<a class='dog-link' href='" + url + "'>"
    ret += options.fn(this)
    ret += "</a>";
        
    return ret;
  });
  
  Handlebars.registerHelper('listenForm', function(listen, options) {
    var url = dog.listenUrl(listen.frame_id, listen.name);
    
    var ret = "<form action='" + url + "' class='dog-form' method='post' accept-charset='utf-8'>"
    ret += options.fn(this)
    ret += "</form>"
    
    return ret;
  });
  
  Handlebars.registerHelper('listenUrl', function(listen) {
    return dog.listenUrl(listen.frame_id, listen.name)
  });
  
  Handlebars.registerHelper('eachKeys', function(context, options) {
    var fn = options.fn, inverse = options.inverse;
    var ret = "";

    var empty = true;
    for (key in context) { empty = false; break; }

    if (!empty) {
      for (key in context) {
          ret = ret + fn({ 'key': key, 'value': context[key]});
      }
    } else {
      ret = inverse(this);
    }
    return ret;
  });
  
  
  scope.dog = dog;
  
  window.onhashchange = function() {
    if(config.performRouting) {
      dog.performRouting()
    }
  }
  
  dog.run()
})(window);