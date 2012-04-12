require "rubygems"
require "sqlite3"
require "sequel"
require 'sequel/plugins/serialization'
require 'digest/md5'
require "json"
require "sinatra/base"
require "sinatra/jsonp"
require "pony"

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

DB.create_table? :journey_one do
  primary_key :id
  foreign_key :user_id
  text :came_to_toronto
  text :love_about_neighborhood
  
  index :user_id
end

DB.create_table? :journey_two do
  primary_key :id
  foreign_key :user_id
  text :sound_url
  text :why
  
  index :user_id
end

DB.create_table? :journey_three do
  primary_key :id
  foreign_key :user_id
  text :story
  string :audio_filename
  string :picture_filename
  
  index :user_id
end

DB.create_table? :journey_four do
  primary_key :id
  foreign_key :user_id
  string :audio_filename
  string :audio_url
  
  index :user_id
end

DB.create_table? :password_recovery_requests do
  primary_key :id
  foreign_key :user_id
  string :code
  
  index :user_id
  index :code
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

class PasswordRecoveryRequests < Sequel::Model(:password_recovery_requests)
  
end

class JourneyOne < Sequel::Model(:journey_one)
  
end

class JourneyTwo < Sequel::Model(:journey_two)
  
end

class JourneyThree < Sequel::Model(:journey_three)
  
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
  
  get '/dog/account.unsubscribe' do
    verify_current_user
    user = current_user
    
    profile = user.profile
    profile["unsubscribe"] = true
    user.profile = profile
    user.save
    
    return jsonp {
      success:true
    }
  end
  
  get '/dog/admin.subscribed_users' do
    admins = ["patorpey@media.mit.edu", "saahmad@mit.edu"]
    
    verify_current_user
    user = current_user
    
    unless user
      return jsonp ({
        success: false,
        errors: ["You need to be logged in as an admin to do this."]
      })
    end
    
    if admins.include? user.email then
      results = []
      
      users = []
      if params[:torontonian]
        users = User.filter(torontonian:true).all
      else
        users = User.all
      end
      
      for user in users do
        user.profile ||= {}
        unless user.profile["unsubscribe"] then
          results << ({
            email:user.email,
            first_name:user.first_name,
            last_name:user.last_name,
            profile: {
              torontonian:user.torontonian
            }
          })
        end
      end
      
      
      return jsonp({
        success:true,
        results: results
      })
    else
      return jsonp({
        success:false,
        errors: ["You are not an administrator."]
      })
    end
    
  end
  
  get '/dog/account.password.recover' do
    
    params[:reset_url] ||= ""
    if params[:reset_url].strip == "" then
      return jsonp ({
        success: false,
        errors: ["You need to provide a reset password url"]
      })
    end
    
    params[:email] ||= ""
    
    if params[:email].strip == "" then
      return jsonp ({
        success: false,
        errors: ["Email cannot be blank"]
      })
    end
    
    user = User.find(:email => params[:email])
    if user.nil? then
      return jsonp ({
        success: false,
        errors: ["Could not find a user with that email (#{params[:email]})."]
      })
    end
    
    recovery_request = nil
    
    DB.transaction do
      recovery_request = PasswordRecoveryRequests.new
      recovery_request.user_id = user.id
      recovery_request.save
      
      recovery_request.code = recovery_request.id.to_s + SecureRandom.hex(16)
      recovery_request.save
    end
    
    reset_url = params[:reset_url] + "?code=#{recovery_request.code}"
    
      body = <<-EOD
Hello! There was a request to change your password. If you did not
make this request, just ignore this email. Otherwise, please click
the link below to change your password:

#{reset_url}

Talk soon! 

EOD
   
   Pony.mail(
      :to => user.email, 
      :from => "Toronto Symphony <dog@toronto.media.mit.edu>",
      :subject => "Reset your password",
      :body => body,
      :via => :smtp, 
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'apps@dormou.se',
        :password             => 'helloworld123',
        :authentication       => :plain,
        :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
      }
    )
    
    return jsonp({
      success: true
    })
  end
  
  get '/dog/account.password.reset' do
   
    params[:code] ||= ""
    if params[:code].strip == "" then
      return jsonp ({
        success: false,
        errors: ["You need to provide a reset password code"]
      })
    end

    if params[:password] != params[:password_confirm] then
      return jsonp ({
        success: false,
        errors: ["Password and Confirmation does not match."]
      })
    end
    
    DB.transaction do
      recovery_request = PasswordRecoveryRequests.find(:code => params[:code])
      user = User.find(:id => recovery_request.user_id)    
      user.password = Digest::MD5.hexdigest params[:password]
      user.save
      
      recovery_request.destroy
    end
    
    return jsonp ({
      success: true,
    })
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
  

  get '/my/journeys/one/save' do
    verify_current_user
    user = current_user
    
    unless user
      return jsonp ({
        success: false,
        errors: ["You need to be logged in to do this."]
      })
    else
      DB.transaction do
        journey = JourneyOne.find_or_create(:user_id => user.id)
        journey.came_to_toronto = params[:came_to_toronto]
        journey.love_about_neighborhood = params[:love_about_neighborhood]
        journey.save
      end
      
      return jsonp({
        success:true
      })
    end
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


  post '/my/journeys/three/save' do
    verify_current_user
    user = current_user
    
    unless user
      return "You have to be logged in to perform this action."
    else
      journey = JourneyThree.find_or_create(:user_id => user.id)
      journey.story = params["story"]
      journey.audio_filename = params["audio"][:filename]
      journey.picture_filename = params["picture"][:filename]
      journey.save
      
      directory = File.join(File.dirname(__FILE__), "public", "journeys", "3")
      audio_name = File.join(directory, "audio", "#{journey.id}_#{journey.audio_filename}")
      picture_name = File.join(directory, "picture", "#{journey.id}_#{journey.picture_filename}")
      
      File.delete(audio_name) if File.exists?(audio_name)
      File.delete(picture_name) if File.exists?(picture_name)
      
      File.open(audio_name, "w") do |f|
        f.write(params['audio'][:tempfile].read)
      end
      
      File.open(picture_name, "w") do |f|
        f.write(params['picture'][:tempfile].read)
      end
      
      redirect params['redirect_to']
    end
  end
  
  post '/my/journeys/four/save' do
    verify_current_user
    user = current_user
    
    unless user
      return "You have to be logged in to perform this action."
    else
      journey = JourneyFour.find_or_create(:user_id => user.id)
      journey.audio_filename = params["audio"][:filename]
      journey.audio_url = params["audio_url"]
      journey.save
      
      directory = File.join(File.dirname(__FILE__), "public", "journeys", "4")
      audio_name = File.join(directory, "audio", "#{journey.id}_#{journey.audio_filename}")
      
      File.delete(audio_name) if File.exists?(audio_name)
      
      File.open(audio_name, "w") do |f|
        f.write(params['audio'][:tempfile].read)
      end
      
      redirect params['redirect_to']
    end
  end

  get '/my/journeys/one' do
    return jsonp(not_logged_in) if not_logged_in
    user = current_user
    
    journey = JourneyOne.find_or_create(:user_id => user.id)
    jsonp({success:true, journey_one:{ came_to_toronto:journey.came_to_toronto, love_about_neighborhood:journey.love_about_neighborhood}})
  end
  
  get '/my/journeys/two' do
    return jsonp(not_logged_in) if not_logged_in
    user = current_user
    
    journey = JourneyTwo.find_or_create(:user_id => user.id)
    jsonp({success:true, journey_two:{ sound_url:journey.sound_url, why:journey.why}})
  end
  
  get '/my/journeys/three' do
    return jsonp(not_logged_in) if not_logged_in
    user = current_user
    
    journey = JourneyThree.find_or_create(:user_id => user.id)
    
    audio = nil
    picture = nil
    
    audio = "http://#{request.host_with_port}/journeys/3/audio/#{journey.id}_#{journey.audio_filename}" if journey.audio_filename
    picture = "http://#{request.host_with_port}/journeys/3/picture/#{journey.id}_#{journey.picture_filename}" if journey.picture_filename
    
    jsonp({
      success:true, 
      journey_three:{ 
        story: journey.story,
        audio: audio,
        picture: picture
      }
    })
  end
  
  get '/my/journeys/four' do
    return jsonp(not_logged_in) if not_logged_in
    user = current_user
    
    journey = JourneyFour.find_or_create(:user_id => user.id)
    
    audio = nil
    
    audio = "http://#{request.host_with_port}/journeys/4/audio/#{journey.id}_#{journey.audio_filename}" if journey.audio_filename
    
    jsonp({
      success:true, 
      journey_four:{ 
        audio_url: journey.audio_url,
        audio: audio
      }
    })
  end

  get '/journeys/one/all' do
    return "#{params[:callback]}(#{JourneyOne.to_json})"
  end
  
  get '/journeys/two/all' do
    return "#{params[:callback]}(#{JourneyTwo.to_json})"
  end
  
  get '/journeys/three/all' do
    output = []
    journeys = JourneyThree.all
    for journey in journeys do
      output << {
        story: journey.story,
        audio: "http://#{request.host_with_port}/journeys/3/audio/#{journey.id}_#{journey.audio_filename}",
        picture: "http://#{request.host_with_port}/journeys/3/picture/#{journey.id}_#{journey.picture_filename}"
      }
    end
    
    return "#{params[:callback]}(#{output.to_json})"
  end
  
  get '/journeys/four/all' do
    output = []
    journeys = JourneyFour.all
    for journey in journeys do
      output << {
        audio_url: journey.audio_url,
        audio: "http://#{request.host_with_port}/journeys/4/audio/#{journey.id}_#{journey.audio_filename}"
      }
    end
    
    return "#{params[:callback]}(#{output.to_json})"
  end
  
end


