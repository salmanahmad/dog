require File.join(File.dirname(__FILE__), "../lib/dog.rb")

# Where does global statements go? - Inside of a Dog.bark! call.
# this call will set up EventMachine and start up the server as
# well.
Dog.bark! do

module Dog::Application
  
  # How do I handle control structures
  
  if 5 == 7 then
    # Something
  else
    # Something else
  end
  
  Track.current.checkpoint do
    # Creating a checkpoint inside of another checkpoint creates an augmented
    # checkpoint number. For example, [5, 1] instead of [6].
    
    # Each condition is saved in the track so we can quickly "catch" 
    # up where we left off.
    Track.current.checkpoint { Variable.named("_dog_conditional_1") = (5 == 7) }
    
    if Variable.named("_dog_conditional_1") then
      Track.current.checkpoint { 
        # Something
      }
    else
      Track.current.checkpoint { 
        # Something else
      }
    end
  end
  
  i = 0
  while i < 7 do
    # Something
  end
  
  Track.current.checkpoint { Variable.named("i") = 0 }
  Track.current.checkpoint do
    Track.current.checkpoint { Variable.named("_dog_conditional_1") = Variable.named("i") < 7 }
    while Variable.named("_dog_conditional_1") do
      Track.current.checkpoint {
        # Something
      }
      
      # Note this order. It is really important. Okay?
      Track.current.reset_checkpoint
      Track.current.checkpoint { Variable.named("_dog_conditional_1") = Variable.named("i") < 7 }
    end
  end
      
  module Handlers
    
    def self.meetings_68b329_1(meeting)
      # How do I do a continue inside of a function with a track?
      # track.reached_checkpoint?(1)
      # track.checkpoint(1) - For example, "foobar('baz') unless track.reached_checkpoint(4)"
      # track.checkpoint - Automatically increment internal checkpoint timestamp.
      
      # Instead of Variable.named can't I just do "local_variables"
      # from the bindings - No. I don't love this idea because it
      # makes the implementation very ruby specific and make things more 
      # difficult if we ever have the need to work. Also, the code will look
      # strange to say the least. Best be verbose but understandable.
      Track.current.checkpoint { Variable.named("requester").value = Person.from_variable(meeting) }
      Track.current.checkpoint { Variable.named("requestee").value = meeting.requested_person }
      Track.current.checkpoint { group = [Variable.named("requestee").value, Variable.named("requester").value] }
      
      track.checkpoint { notify(:via => :email, :recipients => group, :message => "Hey! You guys should get together!") }
    end
  
  end
  
  # Community variable names - This is fine. Global data will be
  # somewhat annoying but the way that we will solve this will be 
  # through migrations which we will need regardless.
  
  # How do I do a fast restart and skip the crap that is in 
  # the Application scope? - The same way that we do it in the
  # normal handlers
  
  # Do I like this? Communities being a variable?
  # It feels like there is some disconnect between this and
  # the way we define Records and Events which is somewhat 
  # concerning - Don't worry about. First of all, no one will
  # be using the Ruby driver initially anyways, so it is not 
  # that big of a deal and we can always add syntactic sugar
  # to make this nicer down the road...
  Track.current.checkpoint do
    Dog::Variable.named("learners").value = Community.new do
    
    end
  end
  
  # Where does Config go and where does that fit in? - Inline we will handle 
  # sinatra configurational stuff as it comes up
  Config.set("default_community", "learners")

  # Classes can be nested. They just can't go inside of a function.
  class Learner < Record
    property "objective", :type => String
    property "learnables", :type => Array
    property "teachables", :type => Array
    property "friends", :type => Relationship, :target_type => self, :target_property => "friends"
    property "pairs", :type => Relationship, :target_type => self, :target_property => "friends"
  end
  
  class ProvideThreeInterests < Task
    property "instructions", :value => "Please provide three things that you are interested in learning and teaching."
    property "objective", :type => String, :required => true, :direction => "output"
    property "learnables", :type => Array, :required => true, :direction => "output"
    property "teachables", :type => Array, :required => true, :direction => "output"
  end
  
  class Match < Message
    property "body", :value => "We found a possible match for you!"
    property "possible_match", :type => Person, :direction => "input"
    property "learnables", :type => Array, :direction => "input"
    property "teachables", :type => Array, :direction => "input"
  end
  
  # LET PEOPLE READ AND WRITE RECORD books
  Server.expose_variable("books", :eligibility => People, :access => :readwrite)
  
  # LET PEOPLE JOIN learners
  Server.expose_community("learners", :eligibility => People, :access => :join)
  
  # LET learner READ AND WRITE pairs
  Server.expose_profile_property("pairs", :eligibility => Learner, :access => :readwrite)
  
  # LET PEOPLE READ AND WRITE PROFILE
  Server.expose_profile_property(:all, :eligibility => People, :access => :readwrite)  
  
  class Meeting < Event 
    property "requested_person", :type => Person, :direction => "input"
  end
  
  # http://ujihisa.blogspot.com/2009/11/accepting-both-get-and-post-method-in.html
  Server.listen(:via => "http", :at => "meetings", :eligibility => People, :event => Meeting, :handler => :meetings_68b329_1)
  
  # How to name handlers for system events - Convert '.' to '_' - Append a signature to all names - Add increment
  Server.listen(:event => ::Dog::Dormouse::Account::Create, :handler => :dormouse_account_create_68b329_1)
  Server.listen(:event => Dormouse::Account::Create, :handler => :dormouse_account_create_d8ad52_1)
end

end