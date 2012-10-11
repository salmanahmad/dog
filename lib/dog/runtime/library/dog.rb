#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module Dog
    include ::Dog::NativePackage

    name "dog"

    structure "array" do

    end

    structure "structure" do

    end

    structure "function" do

    end

    structure "type" do

    end

    structure "query" do
      property "container"
      property "predicate"
    end

    structure "email" do
      property "subject"
      property "body"
    end

    implementation "id:on" do
      argument "value"
      
      body do |track|
        value = variable("value")
        dog_return(::Dog::Value.string_value(value._id))
      end
    end

    implementation "listen:to:for" do
      # TODO - Support type information for sub-keys, etc.
      argument "routing"
      argument "identifier"

      body do |track|
        identifier = variable("identifier")
        routing = variable("routing")
        current_track = track.control_ancestors.last

        if routing.is_null? then
          current_track.listens.delete(identifier.ruby_value)
          dog_return(::Dog::Value.null_value)
        end

        checkpoint do
          dog_call("channel:buffer", "future", [::Dog::Value.number_value(0)])
        end

        checkpoint do
          value = track.stack.pop

          current_track.listens[identifier.ruby_value] = {
            "value" => value,
            "routing" => routing
          }

          dog_return(value)
        end
      end
    end

    implementation "display:value:as:to" do
      argument "value"
      argument "identifier"
      argument "routing"
      
      body do |track|
        value = variable("value")
        identifier = variable("identifier")
        routing = variable("routing")
        
        current_track = track.control_ancestors.last
        current_track.displays[identifier.ruby_value] = {
          "value" => value,
          "routing" => routing
        }
      end
      
    end

    implementation "notify" do
      argument "value"
      argument "query"
      argument "via"

      body do |track|
        value = variable("value")
        query = variable("query")
        via = variable("via")

        if via.ruby_value == "email" then
          settings = ::Dog::Config.get("email")
          
          if settings.nil? then
            dog_return
          end
          
          if query.type == "people.person" then
            address = query["email"]
            if address.nil? || address.is_null? then
              dog_return(Dog::Value.false_value)
            else
              address = address.ruby_value.to_s
            end
          end

          subject = ""
          body = ""

          if value.type == "dog.email" then
            subject = value["subject"]
            body = value["body"]

            if subject.nil? || subject.is_null? then
              subject = ""
            else
              subject = subject.ruby_value.to_s
            end

            if body.nil? || body.is_null? then
              body = ""
            else
              body = body.ruby_value.to_s
            end

          elsif value.type == "dog.string" then
            body = value.ruby_value
          else
            body = value.ruby_value.inspect
          end
          
          unless settings["smtp"] then
            dog_return
          end
          
          via_options = {}
          for key, value in settings["smtp"] do
            via_options[key.intern] = value
          end
          
          envelope = {
            :to => address,
            :from => settings["from"],
            :subject => subject,
            :body => body,
            :via => :smtp,
            :via_options => via_options
          }
          
          Pony.mail(envelope)
          dog_return
        else
          # TODO - I need to implement the push channel via stream. Right now, only email is working
        end
        
      end
    end

    implementation "add:value:to" do
      argument "value"
      argument "container"
      

      body do |current_track|
        container = variable("container")
        value = variable("value")

        if container.type == "dog.collection" then
          collection = container["name"].ruby_value

          value._id = BSON::ObjectId.new
          ::Dog.database[collection].insert(value.to_hash)
          dog_return(value)
        else
          # TODO - I need to handle the "close" message
          if container.pending then
            future = ::Dog::Future.find_one("value_id" => container._id)

            if value.type == "dog.close" then
              ::Dog::Future.remove("value_id" => container._id)
              
              future.value.pending = false
              
              for track_id in future.tracks do
                track = ::Dog::Track.find_one(track_id)
                track.futures[future.value_id] = future.value
                
                ::Dog::Runtime.run_track(track)
              end
              dog_return
            else
              # TODO - Deal with buffer_size and channel_mode here
              if future.value.max_numeric_key then
                index = future.value.max_numeric_key.ceil + 1
              else
                index = 0
              end
              
              index = index.to_f
              
              future.value[index] = value
              future.save

              return_values = []

              for handler in future.handlers do
                handler = ::Dog::Value.from_hash(handler)

                package_name = handler["package"].value
                function_name = handler["name"].value

                package = ::Dog::Runtime.bundle.packages[package_name]
                symbol = package.symbols[function_name]

                if symbol["implementations"].size != 0 then
                  argument_name = symbol["implementations"].first["arguments"].first

                  track = ::Dog::Track.new(function_name, package_name)
                  track.variables[argument_name] = value

                  # TODO - I need to handle the output fromt this and do things
                  # like save the track or read the return value. If there are
                  # multiple tracks with multiple return values then I should return
                  # an array with a list of the values. Note: these values may include
                  # a future - or should it include a "receipt"?
                  ::Dog::Runtime.run_track(track)

                  if track.state == ::Dog::Track::STATE::FINISHED
                    return_value = track.stack.pop
                    unless return_value.nil?
                      return_values << return_value
                    end
                  end
                
                end
              end

              if return_values.size == 0 then
                dog_return(::Dog::Value.null_value)
              elsif return_values.size == 1 then
                dog_return(return_values.first)
              else
                output = ::Dog::Value.new("structure", {})

                return_values.each_index do |index|
                  output[index] = return_values[index]
                end

                dog_return(output)
              end
            end
          else
            if container.max_numeric_key then
              index = container.max_numeric_key.ceil + 1
            else
              index = 0
            end

            index = index.to_f

            container[index] = value
            dog_return(container)
          end
        end
      end
    end

    implementation "find_by_id" do
      argument "container"
      argument "value"
      
      body do |track|
        container = variable("container")
        value = variable("value")
        
        if container.type == "dog.collection" then
          if value.type == "dog.string" then
            value = ::Dog::database[container["name"].ruby_value].find_one({"_id" => value.ruby_value})
          else
            value = ::Dog::database[container["name"].ruby_value].find_one({"_id" => value._id})
          end
          
          value = ::Dog::Value.from_hash(value)
          dog_return(value)
        end
      end
    end

    implementation "find" do
      argument "query"

      body do |track|
        query = variable("query")
        container = query["container"]
        selector = query["predicate"].ruby_value

        if container.type == "dog.collection" then
          results = ::Dog::database[container["name"].ruby_value].find(selector)
          value = ::Dog::Value.empty_array
          
          i = 0
          for result in results do
            result = ::Dog::Value.from_hash(result)
            result["_id"] = ::Dog::Value.string_value(result._id)
            value[i] = result
            i += 1
          end
          
          dog_return(value)
        end

      end
    end

    implementation "remove" do
      argument "query"
      
      body do |track|
        query = variable("query")
        container = query["container"]
        selector = query["predicate"].ruby_value

        if container.type == "dog.collection" then
          results = ::Dog::database[container["name"].ruby_value].remove(selector)
          dog_return(::Dog::Value.true_value)
        end
      end
    end

    implementation "update" do
      argument "container"
      argument "value"

      body do |track|
        container = variable("container")
        value = variable("value")

        if container.type == "dog.collection" then
          ::Dog::database[container["name"].ruby_value].update({"_id" => value._id}, value.to_hash, {:safe => true})
        end

        dog_return(value)
      end
    end

    implementation "save" do
      argument "container"
      argument "value"

      body do |track|
        container = variable("container")
        value = variable("value")
        
        if container.type == "dog.collection" then
          ::Dog::database[container["name"].ruby_value].save(value.to_hash, {:safe => true, :upsert => true})
        elsif container.type == "dog.community" && value.type == "people.person"
          # TODO - I need to add the community profile properties to the person object as a result of saving them TO a communtiy.
          
          community = container["name"]
          
          if value["communities"].is_null? then
            # TODO - "array" - this should be updated with the new way to handle arrays
            value["communities"] = ::Dog::Value.new("array", {})
          end
          
          # TODO - Make it easier to call other dog functions
          track = ::Dog::Track.new
          track.variables["container"] = value["communities"]
          track.variables["value"] = community
          
          proc = ::Dog::Library::Dog.package.symbols["add:value:to"]["implementations"][0]["instructions"]
          proc.call(track)
          
          output = track.stack.last
          value["communities"] = output
          
          ::Dog::database["people"].save(value.to_hash, {:safe => true, :upsert => true})
        end
        
        dog_return(value)
      end
    end

    implementation "delete" do
      argument "container"
      argument "value"

      body do |track|
        container = variable("container")
        value = variable("value")

        if container.type == "dog.collection" then
          ::Dog::database[container["name"].ruby_value].remove({"_id" => value._id}, {:safe => true})
        end

        dog_return(value)
      end
    end
  end
end