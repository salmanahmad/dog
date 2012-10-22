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

TODO - Support other templating libraries

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
  
  var didStartLoadingCallback = function() {};
  var didEndLoadingCallback = function() {};
  
  var willRenderDataCallback = function(data, context) { return data };
  var didRenderDataCallback = function(data, context) { };
  
  dog.queryStringVariable = function(variable) {
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
        var trackId = path[i]
        
        state[viewport] = trackId
        
        var context = $("*[data-dog-viewport='" + viewport + "']:first")
        if($(context).size() > 0) {
          dog.loadTrack(trackId, context)
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
        'autoPermalink':true,
        'templates':'#templates',
        'rootSelector':'root',
        'baseUrl':'/dog'
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
  
  dog.renderTemplate = function(data, context) {
    if(!context) {
      context = $("*[data-dog-viewport=root]:first")
    }

    var originalData = data
    var originalContext = context

    var tracks = [data.track]
    if(data.spawns) {
      for(var i in data.spawns) {
        tracks.push(data.spawns[i])
      }
    }
    
    for(var i in tracks) {
      var data = tracks[i]
      var selector = "";

      if (originalData.track._id == data._id) {
        context = originalContext
      } else {
        context = $(originalContext).data("dog-spawn-viewport");
        context = $("*[data-dog-viewport='" + context + "']:first")
      }

      if($(context).size() == 0) {
        continue;
      }

      if(data.package_name != "") {
        selector = data.package_name + ".";
      }

      if(data.function_name == "@root") {
        data.function_name = config.rootSelector;
      }

      selector += data.function_name;

      for(var i in data.listens) {
        var listen = data.listens[i];
        data.listens[i] = {
          "track_id":data._id,
          "name":i,
          "listen":listen
        }
      }

      selector = selector.replace(/:/g,'-');

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

  dog.loadTrack = function(track, context) {
    var request = $.get(config.baseUrl + "/track/" + track);
    didStartLoadingCallback();
    
    request.success(function(data) {
      dog.renderTemplate(data, context);
    });
    
    request.complete(function() {
      didEndLoadingCallback();
    });
  }
  
  dog.callRootListen = function(listen, data, callback) {
    var action = dog.listenUrl("root", listen);
    dog.callListen(action, data, callback);
  }
  
  dog.callListen = function(action, data, callback) {
    var request = $.ajax({
      type: "POST",
      url: action,
      data: JSON.stringify(data),
      contentType: "application/json"
    });
    
    request.success(function(data) {
      callback(data);
    });
  }
  
  dog.renderRootListen = function(listen, data, context) {
    var action = dog.listenUrl("root", listen);
    dog.renderListen(action, data, context);
  }
  
  dog.renderListen = function(action, data, context) {
    var request = $.ajax({
      type: "POST",
      url: action,
      data: JSON.stringify(data),
      contentType: "application/json"
    });
    
    didStartLoadingCallback();
    
    request.success(function(data) {
      dog.renderTemplate(data, context);
    });
    
    request.complete(function() {
      didEndLoadingCallback();
    })
  }
  
  dog.listenUrl = function(track, name) {
    return config.baseUrl + "/track/" + track + "/" + name;
  }
  
  dog.run = function() {
    $(function() {
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
      
      dog.loadTrack("root")
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
  
  Handlebars.registerHelper('listenLink', function(listen, options) {
    var url = dog.listenUrl(listen.track_id, listen.name);
    var ret = "<a class='dog-link' href='" + url + "'>"
    ret += options.fn(this)
    ret += "</a>";
        
    return ret;
  });
  
  Handlebars.registerHelper('listenForm', function(listen, options) {
    var url = dog.listenUrl(listen.track_id, listen.name);
    
    var ret = "<form action='" + url + "' class='dog-form' method='post' accept-charset='utf-8'>"
    ret += options.fn(this)
    ret += "</form>"
    
    return ret;
  });
  
  Handlebars.registerHelper('listenUrl', function(listen) {
    return dog.listenUrl(listen.track_id, listen.name)
  });
  
  scope.dog = dog;
  
  window.onhashchange = function() {
    if(config.performRouting) {
      dog.performRouting()
    }
  }
  
  dog.run()
})(window)