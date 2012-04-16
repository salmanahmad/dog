#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "../../lib/dog.rb")

Dog::Config.set("default_community", "answerers")

Dog.bark! do
  
  Answerers = Dog::Community.establish("answerers") do
    property "gender", :type => String
    property "expertise", :type => Array
  end
  
  Questions = Dog::Collection.named("questions")
  
  
  
  
  class QuestionSubmissions < Dog::Event
    property "title", :type => String, :direction => "input"
    property "body", :type => String, :direction => "input"
    property "id", :type => String, :direction => "output"
  end
  
  class QuestionSubmissionsHandler < Dog::Handler
    def run
      puts "QuestionSubmissionHandler"
      request = Dog::Variable.named("request").value
      
      puts request.inspect
      
      question = {}
      question["title"] = request.title
      question["body"] = request.body
      question["asker"] = Dog::Variable.named("request").person_id
      question["responses"] = []
      question["answered"] = false
      
      id = Questions.insert(question)
      Dog::reply("id" => id)
    end
  end
  
  Dog::Server.listen(:event => QuestionSubmissions, :at => "/QuestionSubmissions", :eligibility => Dog::People.from("answerers"), :handler => QuestionSubmissionsHandler.new("request"))
  





  class QuestionResponses < Dog::Event
    property "question_id", :type => String, :direction => "input"
    property "body", :type => String, :direction => "input"
  end
  
  class QuestionResponsesHandler < Dog::Handler
    def run
      puts "QuestionResponsesHandler"
=begin
response = question_response
response.responder = PERSON FROM question_response

question = questions["id" == question_response.question_id]
COMPUTE push ON question.responses, response

COMPUTE update ON questions, question
=end
    end
  end
  
  Dog::Server.listen(:event => QuestionResponses, :at => "/QuestionResponses", :eligibility => Dog::People.from("answerers"), :handler => QuestionResponsesHandler.new("request"))



  class ResponseUpvotes < Dog::Event
    property "question_id", :type => String, :direction => "input"
    property "response_index", :type => Numeric, :direction => "input"
  end
  
  class ResponseUpvotesHandler < Dog::Handler
    def run
      puts "ResponseUpvotes"
    end
  end
  
  Dog::Server.listen(:event => ResponseUpvotes, :at => "/ResponseUpvotes", :eligibility => Dog::People.from("answerers"), :handler => ResponseUpvotesHandler.new("request"))
  
  
  
  
  
  class ResponseCorrectIndicators < Dog::Event
    property "question_id", :type => String, :direction => "input"
    property "response_index", :type => Numeric, :direction => "input"
  end

  class ResponseCorrectIndicatorsHandler < Dog::Handler
    def run
      puts "ResponseCorrectIndicators"
    end
  end
  
  Dog::Server.listen(:event => ResponseCorrectIndicators, :at => "/ResponseCorrectIndicators", :eligibility => Dog::People.from("answerers"), :handler => ResponseCorrectIndicatorsHandler.new("request"))



  class QuestionSearchRequests < Dog::Event
    property "query", :type => String, :direction => "input"
    property "questions", :type => Array, :direction => "output"
  end
  
  class QuestionSearchRequestsHandler < Dog::Handler
    def run
      request = Dog::Variable.named("request").value
      
      puts "QuestionSearchRequests"
      puts request.inspect
      
      questions = Questions.find({"$or" => [{"title" => Regexp.new(request.query)}, {"body" => Regexp.new(request.query)}]}).to_a
      Dog::reply("questions" => questions)
    end
  end

  Dog::Server.listen(:event => QuestionSearchRequests, :at => "/QuestionSearchRequests", :eligibility => Dog::People.from("answerers"), :handler => QuestionSearchRequestsHandler.new("request"))



  class QuestionViewRequests < Dog::Event
    property "question_id", :type => String, :direction => "input"
    property "question", :type => Hash, :direction => "output"
  end
  
  class QuestionViewRequestsHandler < Dog::Handler
    def run
      request = Dog::Variable.named("request").value
      
      puts "QuestionViewRequests"
      puts request.inspect
      
      question = Questions.find_one({"_id" => request.question_id})
      Dog::reply("question" => question)
    end
  end

  Dog::Server.listen(:event => QuestionViewRequests, :at => "/QuestionViewRequests", :eligibility => Dog::People.from("answerers"), :handler => QuestionViewRequestsHandler.new("request"))





    
    
    
  
end


