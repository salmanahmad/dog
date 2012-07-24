#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require 'digest/sha1'
require 'set'

require 'thin'
require 'eventmachine'
require 'sinatra/base'
require 'sinatra/async'
require 'uuid'
require 'json'
require 'mongo'

# TODO Add back the Instant Messaging Capabilities.
#require 'blather/client/client'

require File.join(File.dirname(__FILE__), 'runtime/database_object.rb')
require File.join(File.dirname(__FILE__), 'runtime/routability.rb')
require File.join(File.dirname(__FILE__), 'runtime/stream_object.rb')

require File.join(File.dirname(__FILE__), 'runtime/community.rb')
require File.join(File.dirname(__FILE__), 'runtime/config.rb')
require File.join(File.dirname(__FILE__), 'runtime/database.rb')
require File.join(File.dirname(__FILE__), 'runtime/event.rb')
require File.join(File.dirname(__FILE__), 'runtime/handler.rb')
require File.join(File.dirname(__FILE__), 'runtime/kernel_ext.rb')
require File.join(File.dirname(__FILE__), 'runtime/message.rb')
require File.join(File.dirname(__FILE__), 'runtime/person.rb')
require File.join(File.dirname(__FILE__), 'runtime/property.rb')
require File.join(File.dirname(__FILE__), 'runtime/server.rb')
require File.join(File.dirname(__FILE__), 'runtime/task.rb')
require File.join(File.dirname(__FILE__), 'runtime/track.rb')
require File.join(File.dirname(__FILE__), 'runtime/value.rb')
require File.join(File.dirname(__FILE__), 'runtime/variable.rb')
require File.join(File.dirname(__FILE__), 'runtime/vet.rb')

module Dog
  
  # TODO - Right now the runtime is modeled as a singleton object.
  # I may want to move the runtime into an instance-model so that
  # there can be multiple runtimes per process. I am avoiding that
  # for the time being because it would require changes to sinatra.
  
  class Runtime
    class << self
    
      attr_accessor :bite_code
      attr_accessor :bite_code_filename
      attr_accessor :save_set
    
      def run_file(bite_code_filename, options = {})
        run(File.open(bite_code_filename).read, bite_code_filename, options)
      end
      
      def run(bite_code, bite_code_filename, options = {})
        self.save_set = Set.new
        
        options = {
          "config_file" => nil,
          "config" => {},
          "database" => {}
        }.merge!(options)
        
        bite_code = JSON.load(bite_code)
      
        if bite_code["version"] != VERSION::STRING then
          raise "This program was compiled using a different version of Dog. It was compiled with #{bite_code["version"]}. I am Dog version #{VERSION::STRING}."
        end
        
        code = {}
        for filename, ast in bite_code["code"]
          # I need the second call here so that I can initialize the parent pointers in the tree. 
          # I may want to incorporate this into from_hash at some point.
        
          ast = Nodes::Node.from_hash(ast)
          ast.compute_paths_of_descendants
        
          code[filename] = ast
        end
        
        bite_code["code"] = code
        
        self.bite_code = bite_code
        self.bite_code_filename = bite_code_filename
        
        Config.initialize(options["config_file"], options["config"])
        Database.initialize(options["database"])
        Track.initialize_root("root", bite_code["main_filename"])
        
        tracks = Track.find({"state" => Track::STATE::RUNNING}, :sort => ["created_at", Mongo::DESCENDING])
        
        for track in tracks do
          track = Track.from_hash(track)
          run_track(track)
        end
                
        tracks = Track.find({"state" => { 
          "$in" => [Track::STATE::WAITING, Track::STATE::LISTENING, Track::STATE::ASKING]
          }
        }, :sort => ["created_at", Mongo::DESCENDING])
        
        if tracks.count != 0 then
          Server.run
        end
      end
      
      def run_track(track)
        # TODO - check for state first
        # TODO - Right now I have poor support for tail recursion. I may run out of stack space before too long
        # TODO - When do I queue up the tracks that I should save?
        # TODO - When do I delete old tracks?
        
        next_track = nil
        
        return if track.state == Track::STATE::FINISHED || track.state == Track::STATE::LISTENING
        
        loop do
          node = Runtime.node_at_path_for_filename(track.current_node_path, track.function_filename)
          next_track = node.visit(track)
          
          self.save_set.add(track)
          
          if track.state == Track::STATE::ASKING then
            break
          end
          
          if track.state == Track::STATE::FINISHED || track.state == Track::STATE::LISTENING then
            parent_track = Track.find_by_id(track.control_ancestors.last)
            
            if parent_track && !(parent_track.state == Track::STATE::FINISHED || parent_track.state == Track::STATE::LISTENING) then
              
              parent_current_node = Runtime.node_at_path_for_filename(parent_track.current_node_path, parent_track.function_filename)
              parent_track.write_stack(parent_current_node.path, track.read_return_value)
              
              parent_track.current_node_path = parent_current_node.parent.path
              parent_track.state = Track::STATE::RUNNING
              
              run_track(parent_track)
              return
            else
              break
            end
          end
          
          if next_track && next_track.class == Track then
            run_track(next_track)
            return
          end
        end
        
        for t in self.save_set do
          t.save
        end
        
      end

      def symbol_exists?(name = [])
        name = name.join(".")
        if name == "" then
          return true
        else
          return self.bite_code["symbols"].include? name
        end
      end

      def symbol_info(name = [])
        path = self.bite_code["symbols"][name.join(".")].clone
        path.shift

        node = self.node_at_path_for_filename(path, self.bite_code["main_filename"])
        type = self.typeof_node(node)

        if type then
          return self.to_hash_for_stream(name, type)
        else
          return nil
        end
      end

      def symbol_descendants(name = [], depth = 1)
        descendants = []
        name = name.join(".")

        # special case root
        name = '' if name == 'root'

        for symbol, path in self.bite_code["symbols"] do
          if symbol.start_with?(name) then
            level = symbol[name.length, symbol.length].count(".")
            level += 1 if name == '' # implied root. in every name

            if level > 0 && (depth == -1 || level <= depth) then
              path = path.clone
              path.shift

              node = self.node_at_path_for_filename(path, self.bite_code["main_filename"])
              type = self.typeof_node(node)

              if type then
                descendants << self.to_hash_for_stream(symbol.split('.'), type)
              end
            end
          end
        end

        return descendants
      end

      def node_at_path_for_filename(path, file)
        # TODO - I need to raise an error if the node is not found.
        node = self.bite_code["code"][file]

        for index in path do
          node = node[index]
        end

        return node
      end

      def typeof_node(node)
        return case
        when node.class == ::Dog::Nodes::FunctionDefinition
          "function"
        when node.class == ::Dog::Nodes::OnEachDefinition
          "oneach"
        when node.class == ::Dog::Nodes::StructureDefinition
          "structure"
        else
          nil
        end
      end

      def to_hash_for_stream(name, type)
        bag = {
          "id" => name.join("."),
          "name" => name,
          "type" => type
        }
        # FIXME hack to get name right
        # if type == 'oneach'
        #   bag["name"] = bag["name"]["@each:".length, bag["name"].length]
        # end
        return bag
      end

    end

  end

end
