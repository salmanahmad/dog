require "rubygems"
require "pp"
require "sqlite3"
require "sequel"
require 'sequel/plugins/serialization'
require 'csv'
require 'set'
require "json"
require "yaml"

records = YAML.load_file("journey_one.yml")

DB = Sequel.connect("sqlite://dog.db")

class User < Sequel::Model(:users)
  
end


DB.transaction do

for record in records do
  user = User.filter(:email => record["email"]).first
  DB[:journey_one].insert({:user_id => user.id, :came_to_toronto => record["came_to_toronto"], :love_about_neighborhood => record["love_about_neighborhood"] })
end

end