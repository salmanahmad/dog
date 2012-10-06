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
require 'open3'

require 'pony'
require 'thin'
require 'eventmachine'
require 'sinatra/base'
require 'sinatra/async'
require 'uuid'
require 'json'
require 'mongo'
require 'httparty'
require 'json'

# TODO Add back the Instant Messaging Capabilities.
#require 'blather/client/client'

require File.join(File.dirname(__FILE__), 'runtime/database_object.rb')

require File.join(File.dirname(__FILE__), 'runtime/external/facebook_helpers.rb')
require File.join(File.dirname(__FILE__), 'runtime/external/facebook_person.rb')

require File.join(File.dirname(__FILE__), 'runtime/config.rb')
require File.join(File.dirname(__FILE__), 'runtime/database.rb')
require File.join(File.dirname(__FILE__), 'runtime/future.rb')
require File.join(File.dirname(__FILE__), 'runtime/kernel_ext.rb')
require File.join(File.dirname(__FILE__), 'runtime/library.rb')
require File.join(File.dirname(__FILE__), 'runtime/person.rb')
require File.join(File.dirname(__FILE__), 'runtime/server.rb')
require File.join(File.dirname(__FILE__), 'runtime/signal.rb')
require File.join(File.dirname(__FILE__), 'runtime/track.rb')
require File.join(File.dirname(__FILE__), 'runtime/value.rb')
require File.join(File.dirname(__FILE__), 'runtime/vet.rb')

Dir[File.join(File.dirname(__FILE__), "runtime/library", "*.rb")].each { |file| require file }

module Dog
  class Runtime
    class << self
      attr_accessor :bundle
      attr_accessor :bundle_filename
      attr_accessor :bundle_directory
      attr_accessor :scheduled_tracks
      
      def initialize(bundle, bundle_filename = nil, options = {})
        self.bundle = bundle
        self.bundle_filename = File.expand_path(bundle_filename) rescue nil
        self.bundle_directory = File.dirname(File.expand_path(bundle_filename)) rescue Dir.pwd
        
        self.bundle.link(::Dog::Library::System)
        self.bundle.link(::Dog::Library::Collection)
        self.bundle.link(::Dog::Library::Future)
        self.bundle.link(::Dog::Library::Community)
        self.bundle.link(::Dog::Library::People)
        self.bundle.link(::Dog::Library::Dog)
        
        self.scheduled_tracks = Set.new
        
        options = {
          "config_file" => nil,
          "config" => {},
          "database" => {}
        }.merge!(options)
        
        Config.initialize(options["config_file"], options["config"])
        Database.initialize(options["database"])
        
      end
      
      def run_file(bundle_filename, options = {})
        json = File.open(bundle_filename).read
        hash = JSON.load(json)
        bundle = Bundle.from_hash(hash)
        
        self.run(bundle, bundle_filename, options)
      end
      
      def run(bundle, bundle_filename = nil, options = {})
        self.initialize(bundle, bundle_filename, options)
        
        if bundle.dog_version != VERSION::STRING then
          raise "This program was compiled using a different version of Dog. It was compiled with #{bundle.dog_version}. I am Dog version #{VERSION::STRING}."
        end
        
        if ::Dog::Config.get("email") then
          pid = Process.fork
          if pid.nil? then
            require File.join(File.dirname(__FILE__), "runtime/external/mail_receiver.rb")
          else
            Process.detach(pid)
          end
        end
        
        unless Track.root then
          root = Track.new("@root", bundle.startup_package)
          root.save
        end
        
        tracks = Track.find({"state" => Track::STATE::RUNNING}, :sort => ["created_at", Mongo::DESCENDING])
        tracks = tracks.to_a.map do |track|
          track = Track.from_hash(track)
        end

        for track in tracks do
          self.schedule(track)
        end

        tracks = self.resume
        start_stop_server

        return tracks
      end

      def invoke(function, package, args, track = nil)
        track = ::Dog::Track.invoke(function, package, args, track)
        self.schedule(track)
        self.resume
      end

      def schedule(track)
        self.scheduled_tracks.add(track)
      end

      def resume
        resumed_tracks = Set.new

        loop do
          resumed_tracks.merge(self.scheduled_tracks)
          tracks = self.scheduled_tracks.to_a
          if tracks.size == 0
            break
          end

          self.scheduled_tracks = Set.new

          for track in tracks do
            next if track.state != Track::STATE::RUNNING

            loop do
              instructions = track.context["instructions"]
              track.next_instruction = nil

              if instructions.kind_of? Proc then
                signal = instructions.call(track)
              else
                instruction = instructions[track.current_instruction]

                if instruction.nil? then
                  track.finish
                else
                  begin
                    signal = instruction.execute(track)
                  rescue Exception => e
                    exception = Exception.new("Dog error on line: #{instruction.line} in file: #{instruction.file}.\n\nThe ruby error was: #{e.to_s}")
                    exception.set_backtrace(e.backtrace)
                    raise exception
                  end

                  if track.next_instruction then
                    track.current_instruction = track.next_instruction
                  else
                    track.current_instruction += 1
                  end
                end
              end

              if signal.kind_of?(Signal) && signal.call_track then
                track = signal.call_track
              end

              if signal.kind_of?(Signal) && signal.schedule_tracks then
                for t in signal.schedule_tracks do
                  self.schedule(t)
                end
              end
              
              if signal.kind_of?(Signal) && signal.stop then
                # TODO - Will this cause simple programs to hang and deadlock?
                # Perhaps that is okay because it is used with a stop command 
                # which means it is always used with a running server app
                track.state = Track::STATE::WAITING
                track.save
                break
              end

              if track.state == Track::STATE::WAITING then
                track.save
                break
              end

              if track.state == Track::STATE::FINISHED then
                return_value = track.stack.last || ::Dog::Value.null_value
                return_track = track.control_ancestors.last

                if return_track then
                  if return_track.kind_of?(::BSON::ObjectId) then
                    return_track = Track.find_by_id(return_track)
                  end

                  for name, future in track.futures do
                    # TODO - What the crapper is going on here?
                    future = future.to_hash
                    future = ::Dog::Future.from_hash(future)
                    return_track.futures[name] = future
                  end

                  return_track.stack.push(return_value)
                  return_track.state = Track::STATE::RUNNING

                  track.remove
                  track = return_track
                else
                  # TODO - If this was a spawned track, then I should notify anyone that is waiting on my future since spawn should return a future...
                  if track.is_root? then
                    track.save
                  else
                    track.remove
                  end

                  break
                end
              end
            end
          end
        end

        return resumed_tracks.to_a
      end

      def start_stop_server
        tracks = Track.find({"state" => Track::STATE::WAITING}, :sort => ["created_at", Mongo::DESCENDING])
        
        root_track = Track.root
        if root_track.displays.keys.count > 0 || root_track.listens.keys.count > 0 then
          root_has_listen = true
        else
          root_has_listen = false
        end

        if tracks.count > 0 || root_has_listen then
          Server.run
        end
      end

    end

  end

end
