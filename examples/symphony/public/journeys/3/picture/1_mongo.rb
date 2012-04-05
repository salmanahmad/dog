require "rubygems"
require "mongo"
require "mongo_mapper"
require "delegate"

db = Mongo::Connection.new.db("test")

cursor = db["users"].find({"asdfasd" => 123})
puts cursor
puts cursor.count

db["variables"].insert({monkies: Time.now})


variables = db["variables"].find({})
puts variables.count
puts variables[0]

__END__

MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = "test"

puts "Hi".to_mongo
puts 5.to_mongo

class Structure
  def to_mongo
    {"key" => "value"}
  end
end

class Variable
  include MongoMapper::Document
  set_collection_name "variables"
  
  before_save :update_value
  after_save :revert_value
  
  key :value
  
  def update_value
    @_value = self.value
    self.value = self.value.to_mongo
  end
  
  def revert_value
    self.value = @_value
    @_value = nil
  end
end

record = Structure.new

var = Variable.new
var.value = record
var.save
puts var.value
