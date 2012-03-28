require File.join(File.dirname(__FILE__), "../../lib/dog.rb")

Dog::Config.set("database_adapter", "sqlite3")
Dog::Config.set("database_name", "database.db")

Dog.bark! do
  
  include Dog
  
  class LearningRequest < Event
    property "learnables", :type => String, :direction => "input"
  end
  
  class ProvideObjective < Task
    property "objectives", :type => String, :direction => "output"
  end
  
  class PickTeacher < Task
    property "choices", :type => ::Dog::Person, :direction => "input"
    property "pick", :type => ::Dog::Person, :direction => "output"
  end
  
  class MeetingConfirmation < Message
    property "teacher", :type => ::Dog::Person, :direction => "input"
  end
  
  class Login < Workflow
    property "instructions"
    
    def run
      
    end
  end
  
  class LearningRequestHandler < Handler
    def run
      user = Dog::Variable.named("learning_request").person
      objectives = Dog::ask(user, ProvideObjective.new())
      
      if user.public? then
        user = Dog::ask(user, Login)
      end
      
      teacher = Dog::ask(user, PickTeacher.new(:choices => ["Foo", "Bar"]))
      Dog::notify(user, MeetingConfirmation.new)
    end
  end
  
  
  Server.listen(:via => "http", :at => "learning_request", :eligibility => People, :event => LearningRequest, :handler => LearningRequestHandler, :variable_name => "learning_request")
  

end