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
    property "learnable", :type => String, :direction => "input"
    property "teachers", :type => Array, :direction => "output"
  end
  
  class MatchedTeachers < Dog::Event
    property "teachers", :type => Array, :direction => "output"
  end
  
  class MeetingConversation < Dog::Event
    # TODO - Some sort of person type in event...
    property "person", :type => String, :direction => "input"
  end
  
  class Conversation < Dog::Workflow
    people "conversants"
    
    def run
      puts "Hello, Here!"
    end
  end
  
  class FindTeacherHandler < Dog::Handler
    def run
      request = Dog::Variable.named("request")
      teachers = Dog::Person.find(Dog::People.from("learners").where("teachables" => request.value.learnable)).to_a
      Dog::reply("teachers" => teachers)
    end
  end
  
  class MatchedTeachersHandler < Dog::Handler
    def run
      request = Dog::Variable.named("request")
      person = Dog::Person.from(request)
      
      person.profile["learners"]["learnables"] ||= []
      teachers = Dog::Person.find(Dog::People.from("learners").where("teachables" => {"$in" => person.profile["learners"]["learnables"]})).to_a
      teachers.map! do |teacher|
        teacher = Dog::Person.from_hash(teacher)
        teacher.to_hash_for_event
      end
      Dog::reply("teachers" => teachers)
    end
  end
  
  class MeetingConversationHandler < Dog::Handler
    def run
      request = Dog::Variable.named("request")
      requester = Dog::Person.from(request)
      
      requestee = Dog::Person.find_by_id(request.value.person)
      
      Dog::ask([requester, requestee], Conversation.new())
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
  Dog::Server.listen(:event => MatchedTeachers, :at => "matched_teachers", :eligibility => Dog::People, :handler => MatchedTeachersHandler.new("request"))
  Dog::Server.listen(:event => MeetingConversation, :at => "meet", :eligibility => Dog::People, :handler => MeetingConversationHandler.new("request"))
  
end


