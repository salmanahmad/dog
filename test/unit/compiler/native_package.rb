
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

module Foo
  include ::Dog::NativePackage
  
  structure "person" do
    property "age"
  end
end
