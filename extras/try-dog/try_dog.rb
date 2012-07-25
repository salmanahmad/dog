require 'sinatra'

helpers do
  def dog
    File.join(File.dirname(__FILE__), "../../bin/dog")
  end
end

get '/' do
  redirect '/index.html'
end

get '/evaluate' do
  
  track = params["track"]
  statement = params["statement"]
  if track then
    `#{dog} shell -t #{track} "#{statement}"`
  else
    `#{dog} shell "#{statement}"`
  end
end

get '/version' do
  `#{dog} version`
end