
/*

TODO - Add support for displays track references
TODO - Allow for named templates and cascading template selection
TODO - Allow developers to change the template used with callback

TODO - Javascript API to send listen dynamically (includes API calls with returns)
TODO - Javascript API to authenticate and to check the authentication status

TODO - Permalink solution / URL updating
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
  var initialized = false;
  
  var did_start_loading_callback = function() {};
  var did_end_loading_callback = function() {};
  
  var will_render_data_callback = function(data, context) { return data };
  var did_render_data_callback = function(data, context) { };
  
  dog.initialize = function(options) {
    if(!initialized) {
      initialized = true;
      config = options || {
        'templates':'#templates',
        'root_selector':'root',
        'base_url':'/dog'
      };
    }
  }
  
  dog.did_start_loading = function(callback) {
    did_start_loading_callback = function() {
      if(callback) {
        callback();
      }
    }
  }
  
  dog.did_end_loading = function(callback) {
    did_end_loading_callback = function() {
      if(callback) {
        callback();
      }
    }
  }
  
  dog.will_render_data = function(callback) {
    will_render_data_callback = function(data, context, request) {
      if(callback) {
        return callback(data, context, request)
      } else {
        return data
      }
    }
  }
  
  dog.did_render_data = function(callback) {
    did_render_data_callback = function(data, context, request) {
      if(callback) {
        callback(data, context, request);
      }
    }
  }
  
  dog.render_template = function(data, context) {
    if(!context) {
      context = $("*[data-dog-viewport=root]:first")
    }

    var original_data = data
    var original_context = context

    var tracks = [data.track]
    if(data.spawns) {
      for(var i in data.spawns) {
        tracks.push(data.spawns[i])
      }
    }

    for(var i in tracks) {
      var data = tracks[i]
      var selector = "";

      if (original_data.track._id == data._id) {
        context = original_context
      } else {
        context = $(original_context).data("dog-spawn-viewport");
        context = $("*[data-dog-viewport='" + context + "']:first")
      }

      if($(context).size() == 0) {
        continue;
      }

      if(data.package_name != "") {
        selector = data.package_name + ".";
      }

      if(data.function_name == "@root") {
        data.function_name = config.root_selector;
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

        data = will_render_data_callback(data, context, original_data)
        html = template(data);

        if($(context).data("dog-update-strategy") == "replace") {
          $(context).html(html);
        } else if ($(context).data("dog-update-strategy") == "append") {
          $(context).append(html);
        } else {
          $(context).html(html);
        }

        did_render_data_callback(data, context, original_data)
      }
    }
  }

  dog.load_track = function(track, context) {
    var request = $.get(config.base_url + "/track/" + track);
    did_start_loading_callback();
    
    request.success(function(data) {
      dog.render_template(data, context);
    });
    
    request.complete(function() {
      did_end_loading_callback();
    });
  }
  
  dog.send_listen = function(action, data, context) {
    var request = $.ajax({
      type: "POST",
      url: action,
      data: JSON.stringify(data),
      contentType: "application/json"
    });
    
    did_start_loading_callback();
    
    request.success(function(data) {
      dog.render_template(data, context);
    });
    
    request.complete(function() {
      did_end_loading_callback();
    })
  }
  
  dog.listen_url = function(listen) {
    return config.base_url + "/track/" + listen.track_id + "/" + listen.name;
  }
  
  dog.run = function() {
    dog.initialize();
    dog.load_track("root");
  }
  
  $(".dog-form").live("submit", function() {
    var context = $(this).parents("*[data-dog-viewport]:first");
    dog.send_listen($(this).attr("action"), $(this).serializeObject(), context);
    return false;
  })
  
  $(".dog-link").live("click", function() {
    var context = $(this).parents("*[data-dog-viewport]:first");
    var data = $(this).serializeAnything()
    
    dog.send_listen($(this).attr("href"), data, context);
    return false;
  });
  
  Handlebars.registerHelper('listen_link', function(listen, options) {
    var url = dog.listen_url(listen);
    var ret = "<a class='dog-link' href='" + url + "'>"
    ret += options.fn(this)
    ret += "</a>";
        
    return ret;
  });
  
  Handlebars.registerHelper('listen_form', function(listen, options) {
    var url = dog.listen_url(listen);
    
    var ret = "<form action='" + url + "' class='dog-form' method='post' accept-charset='utf-8'>"
    ret += options.fn(this)
    ret += "</form>"
    
    return ret;
  });
  
  Handlebars.registerHelper('listen_url', function(listen) {
    return dog.listen_url(listen)
  });
  
  Handlebars.registerHelper('link_data', function(data) {
    return data;
  });
  
  scope.dog = dog;
  
  $(function() {
    dog.run()
  })
})(window)