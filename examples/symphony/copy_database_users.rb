require "rubygems"
require "pp"
require "sqlite3"
require "sequel"
require 'sequel/plugins/serialization'
require 'csv'
require 'set'
require "json"

columns = ["key","user_name","password","creation_date","first_name","last_name","email","age","torontonian","address","postal_code","neighborhood","musicality","tester","registration_ua","registration_ip"]
main_properties = ["email", "password", "first_name", "last_name"].to_set

DB = Sequel.connect("sqlite://dog.db")

class User < Sequel::Model(:users)
end

puts DB[:users].all


DB.transaction do

  CSV.foreach('users.csv', :col_sep => ";")  do |row|
  
    insertion = {}
    profile = {}
  
    row.each_index do |i|
      column_name = columns[i]
      if main_properties.include? column_name then
        insertion[column_name.intern] = row[i]
      else
        profile[column_name.intern] = row[i]
      end
    end
    
    insertion[:profile] = profile.to_json
    pp insertion
    
    DB[:users].insert(insertion) rescue nil
    
    puts
    puts
    
  end
  
end

puts "Done"

#users = YAML::parse(File.open("users.yml"))




