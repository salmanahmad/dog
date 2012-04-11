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
  
  class FindTeacher < Dog::Event
    property "teachable", :type => String, :direction => "input"
    property "teachers", :type => Array, :direction => "output"
  end
  
  class FindTeacherHandler < Dog::Handler
    def run
      request = Dog::Variable.named("request")
      Dog::reply("teachers" => [request.value.teachable])
    end
  end
  
  class CreateAccountHandler < Dog::Handler
    def run
      variable = Dog::Variable.named("account_create")
      interests = Dog::Variable.named("interests")
      
      interests.value = Dog::ask(Dog::People.where("_id" => variable.person_id), ProvideThreeInterests.new)
      interests.save
      
      output = Dog::Variable.named("interests").value.first
      
      person = Dog::Person.from(output)
      puts person
      
      person.update_profile({
        "learners" => output
      })
      person.save
      
      puts "Here I am ! #{output}"
    end    
  end
  
  
  Dog::Server.listen(:event => Dog::SystemEvents::Account::Create, :handler => CreateAccountHandler.new("account_create"))
  Dog::Server.listen(:event => FindTeacher, :at => "find_teacher", :eligibility => Dog::People, :handler => FindTeacherHandler.new("request"))
  
end


