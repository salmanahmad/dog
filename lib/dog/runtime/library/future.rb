#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module Future
    include ::Dog::NativePackage

    name "future"

    implementation "future" do
      body do
        value = ::Dog::Value.empty_structure
        value.pending = true
        value.buffer_size = 0
        value.channel_mode = false

        # TODO - Implement the garbage collection for futures
        future = ::Dog::Future.new(value._id)
        future.queue_size = 0
        future.save
        
        dog_return(value)
      end
    end

    implementation "channel:buffer" do
      argument "size"

      body do
        size = variable("size").ruby_value

        value = ::Dog::Value.empty_structure
        value.pending = true
        value.buffer_size = size
        value.channel_mode = true

        # TODO - Implement the garbage collection for futures
        future = ::Dog::Future.new(value._id)
        future.queue_size = size
        future.save

        dog_return(value)
      end
    end

    implementation "is:value:from_future" do
      argument "value"
      argument "future"
      
      body do |track|
        value = variable("value")
        future = variable("future")
        
        if value.from_future == future._id || value._id == future._id then
          dog_return(::Dog::Value.true_value)
        else
          dog_return(::Dog::Value.false_value)
        end
        
      end
    end
    
    implementation "register:handler:for" do
      argument "handler"
      argument "future"
      
      body do |track|
        handler = variable("handler")
        future = variable("future")
        
        if future.pending then
          future = ::Dog::Future.find_one({"value_id" => future._id})
          
          future.handlers << ("#{handler["package"].value}.#{handler["name"].value}")
          future.save
        end
      end
    end

    implementation "complete:future:with" do
      argument "future"
      argument "value"
      
      body do |track|
        future = variable("future")
        value = variable("value")
        
        if future.pending
          value.from_future = future._id
          
          future = ::Dog::Future.find_one({"value_id" => future._id})
          future.value = value

          signal = ::Dog::Signal.new
          signal.schedule_tracks = []
          
          for track_id in future.blocking_tracks do
            track_to_schedule = ::Dog::Track.find_by_id(track_id)
            track_to_schedule.state = ::Dog::Track::STATE::RUNNING
            signal.schedule_tracks << track_to_schedule
          end

          for track_id in future.broadcast_tracks do
            do_not_schedule = false

            ::Dog::Runtime.scheduled_tracks.each do |t|
              if t._id == track_id then
                do_not_schedule = true
              end
            end

            unless do_not_schedule then
              Future.remove_broadcast_track_from_all(track_id)

              track_to_schedule = ::Dog::Track.find_by_id(track_id)
              track_to_schedule.stack.push(value)
              track_to_schedule.state = ::Dog::Track::STATE::RUNNING
              signal.schedule_tracks << track_to_schedule
            end
          end

          for handler in future.handlers do
            handler = handler.split(".")
            track_to_schedule = ::Dog::Track.invoke(handler[1], handler[0], [value])
            track_to_schedule.state = ::Dog::Track::STATE::RUNNING
            signal.schedule_tracks << track_to_schedule
          end

          future.blocking_tracks = []
          future.broadcast_tracks = []

          future.save
          set_signal(signal)
        end
      end
    end

    implementation "send:to:value" do
      argument "channel"
      argument "value"

      body do |track|
        # TODO - Respect the queue_size if it is full. We need several backoff strategies
        # - Block
        # - Ignore
        # - Timeout

        channel = variable("channel")
        value = variable("value")

        if channel.pending then
          value.from_future = channel._id
          
          future = ::Dog::Future.find_one({"value_id" => channel._id})
          
          if future then
            if future.broadcast_tracks.empty? && future.handlers.empty? then
              if future.queue_size > 0 then
                future.queue << value
                future.save
              end
            else
              signal = ::Dog::Signal.new
              signal.schedule_tracks = []
              
              for track_id in future.broadcast_tracks do
                do_not_schedule = false
                
                ::Dog::Runtime.scheduled_tracks.each do |t|
                  if t._id == track_id then
                    do_not_schedule = true
                  end
                end
                
                unless do_not_schedule then
                  ::Dog::Future.remove_broadcast_track_from_all(track_id)
                  
                  track_to_schedule = ::Dog::Track.find_by_id(track_id)
                  track_to_schedule.stack.push(value)
                  track_to_schedule.state = ::Dog::Track::STATE::RUNNING
                  signal.schedule_tracks << track_to_schedule
                end
              end
              
              for handler in future.handlers do
                handler = handler.split(".")
                track_to_schedule = ::Dog::Track.invoke(handler[1], handler[0], [value])
                track_to_schedule.state = ::Dog::Track::STATE::RUNNING
                signal.schedule_tracks << track_to_schedule
              end
              
              future.broadcast_tracks = []
              future.save
              set_signal(signal)
            end
          else
            ::Dog::Helper.warn("I could not find a future when attempting to send a message. Garbage collection error?")
          end
        end
      end
    end
  end
end
