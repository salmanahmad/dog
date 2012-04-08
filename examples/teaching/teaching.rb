#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "../../lib/dog.rb")

Dog::Config.set("default_community", "learners")

Dog.bark! do
  
  Learners = Dog::Community.establish("learners") do
    property "objective", :type => String
    property "teachables", :type => Array
    property "learnables", :type => Array
  end
  
  class ProvideThreeInterests < Dog::Task
    property "instructions", :value => "Please provide three things that you are interested in learning and teaching."
    property "objective", :type => String, :required => true, :direction => "output"
    property "learnables", :type => Array, :required => true, :direction => "output"
    property "teachables", :type => Array, :required => true, :direction => "output"
  end
  
  class Match < Dog::Message
    property "body", :value => "We found a possible match for you!"
    property "possible_match", :type => String, :direction => "input"
    property "learnables", :type => Array, :direction => "input"
    property "teachables", :type => Array, :direction => "input"
  end
  
  class CreateAccountHandler < Dog::Handler
    def run
      
    end    
  end
  
  Dog::Server.listen(:event => Dog::SystemEvents::Account::Create, :handler => CreateAccountHandler, :variable => "account_create")
  
end


