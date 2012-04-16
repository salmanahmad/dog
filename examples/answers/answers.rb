#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "../../lib/dog.rb")


Dog.bark! do
  
  Questions = Dog::Collection.named("questions");
  
  class Dog::Server < Sinatra::Base
    
    
    post "/QuestionSubmissions" do
      content_type 'application/json'
      
      question = {}
      question["title"] = params["title"]
      question["body"] = params["body"]
      question["asker"] = session[:current_user]
      question["responses"] = []
      question["answered"] = false
      
      id = Questions.insert(question)
      
      {"id" => id.to_s}.to_json
    end
    
    get "/QuestionSearchRequests" do
      content_type 'application/json'
      
      params["query"] ||= ""
      
      Questions.find({
        "$or" => [
          {"title" => Regexp.new(params["query"], true)},
          {"body" => Regexp.new(params["query"], true)},
        ],
        "title" => { "$ne" => nil },
        "body" => { "$ne" => nil }
      }).to_a.to_json
    end
    
    get "/Questions" do
      content_type 'application/json'
      
      Questions.find_one({"_id" => BSON::ObjectId.from_string(params["id"])}).to_json
    end
    
    post "/QuestionResponses" do
      content_type 'application/json'
      
      id = BSON::ObjectId.from_string(params["question_id"])
      question = Questions.find_one({"_id" => id}).to_json
      puts id
      puts question
      
      if question.nil? then
        return 403
      else
        Questions.update({"_id" => id}, {"$push" => { "responses" => params["body"] }})
        return 200
      end
    end
    
  end
    
    
    
  
end


