#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "../../lib/dog.rb")

Dog::Config.set("port", 5000)
Dog::Config.set("default_community", "vark")

$tasks = {}

class Question
  attr_accessor :category
  attr_accessor :body
  attr_accessor :state
  attr_accessor :asker
  
  def categorize(q)
    self.body = q
    self.state = "initial"
    
    if self.body.index /computer/i
      self.category = "computer"
    elsif self.body.index /surfing/i
      self.category = "surfing"
    elsif self.body.index /programming/i
      self.category = "programming"
    elsif self.body.index /piano/i
      self.category = "piano"
    elsif self.body.index /boston/i
      self.category = "boston"
    elsif self.body.index /san fran/i
      self.category = "san fran"
    elsif self.body.index /chicago/i
      self.category = "chicago"
    elsif self.body.index /cqa/i
      self.category = "cqa"
    end
  end
  
end

Dog.bark! do
  
  Vark = Dog::Community.establish("vark") do
    property "location", :type => String
    property "expertise", :type => Array
  end
  
  EM.next_tick do
    
    client = ::Blather::Client.setup 'aardvark@dormou.se', 'helloworld123'
    
    client.register_handler(:ready) do
      puts ">> Connected to gchat at #{client.jid.stripped}"
    end
    
    client.register_handler :subscription, :request? do |s|
      client.write s.approve!
    end
    
    client.register_handler :message, :chat?, :body do |m|
      handle = m.from.to_s
      handle = handle.split("/").first
      
      user = Dog::Person.find_by_google(handle.to_s)
      if user then
        tasks = $tasks[user.id]
        tasks ||= []
        task = tasks.first
        
        if task then
          if task.state == "initial" then
            task.state = "pending"
            body = m.body
            body ||= ""
            if body.index /yes/i then
              message = "Great, here it is:"
              client.write Blather::Stanza::Message.new(handle, message)
              client.write Blather::Stanza::Message.new(handle, task.body)
            else
              message = "Okay, no problem!"
              client.write Blather::Stanza::Message.new(handle, message)
            
              message = "Sorry! I could not find anyone right now. Please try again."
              client.write Blather::Stanza::Message.new(task.asker, message)
              $tasks[user.id] = nil
            end
          else
            
            
            client.write Blather::Stanza::Message.new(handle, "Thanks so much. I'll send that along.")
            client.write Blather::Stanza::Message.new(task.asker, "I got an answer for you from *#{handle}*.")
            client.write Blather::Stanza::Message.new(task.asker, m.body)
            
            $tasks[user.id] = nil
          end
        else
          message = "Hey! I'll try to find someone who can answer that for you."
          client.write Blather::Stanza::Message.new(handle, message)
          
          question = Question.new
          question.categorize(m.body)
          question.asker = handle
          
          people = Dog::Person.find(Dog::People.from("vark").where({"expertise" => question.category})).to_a
          
          if people.empty? then
            message = "Sorry! I could not find anyone right now. Please try again."
            client.write Blather::Stanza::Message.new(handle, message)
          else
            person = people.first
            $tasks[person["_id"]] = [question]
            
            message = "Hi! I have a question for you about *#{question.category}*. Do you have time to answer it?"
            client.write Blather::Stanza::Message.new(person["google"], message)
          end
          
        end
      else
        client.write Blather::Stanza::Message.new(handle, "Hi! This is Dog!")
        client.write Blather::Stanza::Message.new(handle, "I see that you are not registered. Please go to http://saahmad.media.mit.edu:5000/ to register for Aardvark.")
      end
      
    end
    
    client.connect
    
  end

  
end


