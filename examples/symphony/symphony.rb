require "rubygems"
require "sqlite3"
require "sequel"
require 'sequel/plugins/serialization'
require 'digest/md5'
require "json"
require "sinatra/base"
require "sinatra/jsonp"

DB = Sequel.connect("sqlite://dog.db")

DB.create_table? :users do
  primary_key :id
  string :email
  string :password
  string :first_name
  string :last_name
  text :profile
  boolean :torontonian
  date :created_at
  
  index :email, :unique => true
end

DB.create_table? :journey_two do
  primary_key :id
  foreign_key :user_id
  text :sound_url
  
  index :user_id
end


class Time 
  def to_json 
    to_s.to_json 
  end 
end 
class Sequel::Dataset 
  def to_json 
    naked.all.to_json 
  end 
end 
class Sequel::Model 
  def self.to_json 
    dataset.to_json 
  end 
end 


class User < Sequel::Model(:users)
  plugin :serialization, :json, :profile
end

class JourneyTwo < Sequel::Model(:journey_two)
  
end

class Symphony < Sinatra::Base
  
  enable :logging  
  enable :sessions
  
  after do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Methods'] = 'POST, PUT, GET, DELETE, OPTIONS'
    response['Access-Control-Max-Age'] = "1728000"
  end

  options '/*' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Methods'] = 'POST, PUT, GET, DELETE, OPTIONS'
    response['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    response['Access-Control-Max-Age'] = '1728000'
    response['Content-Type'] = 'text/plain'
    return ''
  end
  
  helpers Sinatra::Jsonp
  helpers do
    def current_user
      if session[:current_user] 
        User[session[:current_user]]
      else
        nil
      end
    end
    
    def not_logged_in
      if session[:current_user] then
        return false
      else
        return { 
          success: false, 
          errors: ["You need to be part of the Torontonian community to perform this task."]
        }
      end
    end
    
    def verify_current_user
      unless session[:current_user] then
        return jsonp ({ 
          success: false, 
          errors: ["You need to be part of the Torontonian community to perform this task."]
        })
      end
    end
  end

  get '/dog/account.info' do    
    user = current_user
    if user
      values = user.values
      values[:profile] = user.profile
      return jsonp ({success: true, info:values })
    end
  end  

  get '/dog/account.status' do    
    if session[:current_user]
      return jsonp ({success: true, logged_in: true})
    else
      return jsonp ({success: true, logged_in: false})
    end
  end
  
  get '/dog/account.login' do
    user = User.find(:email => params[:email])
    response = {}
        
    if user && user.password == Digest::MD5.hexdigest(params[:password])
      response = {success:true}
      session[:current_user] = user.id
    else
      response = {success:false, errors: ["Wrong Username/Email password combination"]}
    end
    
    return jsonp response
  end

  get '/dog/account.logout' do
    session.clear
    return jsonp {
      success:true
    }
  end
  
  get '/dog/account.create' do
    
    if params[:email].strip == "" then
      return jsonp ({
        success: false,
        errors: ["Email cannot be blank"]
      })
    end

    unless params[:email] =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
      return jsonp ({
        success: false,
        errors: ["Your email address does not appear to be valid"]
      })
    end

    if params[:password] != params[:password_confirm] then
      return jsonp ({
        success: false,
        errors: ["Password and Confirmation does not match."]
      })
    end
    
    user = User.find(:email => params[:email])
    
    if user then
      return jsonp ({
        success:false, 
        errors:["Email has already been used."]
      })
    end
    
    user = User.new
    user.email = params[:email]
    user.first_name = params[:first_name]
    user.last_name = params[:last_name]
    user.profile = params[:profile]
    user.password = Digest::MD5.hexdigest params[:password]
    user.save
    
    session[:current_user] = user.id
    
    return jsonp ({
      success: true
    })
  end
  
  
  get '/my/journeys/two/save' do
    verify_current_user
    user = current_user
    
    unless user
      return jsonp ({
        success: false,
        errors: ["You need to be logged in to do this."]
      })
    else
      DB.transaction do
        journey = JourneyTwo.find_or_create(:user_id => user.id)
        journey.sound_url = params[:sound_url]
        journey.why = params[:why]
        journey.save
      end
      
      return jsonp({
        success:true
      })
    end
  end
  
  get '/my/journeys/two' do
    return jsonp(not_logged_in) if not_logged_in
    user = current_user
    
    journey = JourneyTwo.find_or_create(:user_id => user.id)
    jsonp({success:true, journey_two:{ sound_url:journey.sound_url, why:journey.why}})
  end
  
  get '/journeys/two/all' do
    return "#{params[:callback]}(#{JourneyTwo.to_json})"
  end
  
end


