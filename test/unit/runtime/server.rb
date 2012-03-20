#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::ServerTest < RuntimeTestCase  
  #ENV['RACK_ENV'] = 'test'
  include Rack::Test::Methods
  
  def app
    track = Dog::Track.new
    ::Dog::Server.global_track = track
    ::Dog::Server.boot
  end
  
  def test_create_without_email
    get '/dog/account.create'
    assert last_response.client_error?
  end
  
  def test_create_with_email
    post '/dog/account.create', {"email" => "foo@foobar.com"}
    assert last_response.ok?
    user_id = last_request.env['rack.session'][:current_user]
    assert user_id.match(/[\d\w]{8}-[\d\w]{4}-[\d\w]{4}-[\d\w]{4}-[\d\w]{12}/)
    
    post '/dog/account.create', {"email" => "foo@foobar.com"}
    assert last_response.client_error?
    assert_equal last_request.env['rack.session'][:current_user], user_id
  end
  
  def test_login_status
    post '/dog/account.create', {"email" => "foo@foobar.com"}
    assert last_response.ok?
    user_id = last_request.env['rack.session'][:current_user]
    assert user_id.match(/[\d\w]{8}-[\d\w]{4}-[\d\w]{4}-[\d\w]{4}-[\d\w]{12}/)
    
    post '/dog/account.status'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal data["logged_in"], true
    
    post '/dog/account.logout'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    
    post '/dog/account.status'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal data["logged_in"], false
  end

  def test_login
    post '/dog/account.create', {"email" => "foo@foobar.com", "password" => "foobar"}
    assert last_response.ok?
    user_id = last_request.env['rack.session'][:current_user]
    assert user_id.match(/[\d\w]{8}-[\d\w]{4}-[\d\w]{4}-[\d\w]{4}-[\d\w]{12}/)
    
    post '/dog/account.status'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal data["logged_in"], true
    
    post '/dog/account.logout'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    
    post '/dog/account.status'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal data["logged_in"], false
    
    post '/dog/account.login', {"email" => "foo@foobar.com", "password" => ""}
    assert last_response.client_error?
    
    post '/dog/account.status'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal data["logged_in"], false
    
    post '/dog/account.login', {"email" => "foo@foobar.com", "password" => "foobar"}
    assert last_response.ok?
    
    post '/dog/account.status'
    data = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal data["logged_in"], true
  end

  
end

