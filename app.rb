require 'sinatra'

# NOTE: ENV variables should be set directly in terminal for testing on localhost

# Talk to Facebook
get '/webhook' do
  $stderr.puts "ENV => #{ENV['VERIFY_TOKEN']}"
  $stderr.puts "TOKEN => #{params['hub.verify_token']}"
  params['hub.challenge'] if ENV["VERIFY_TOKEN"] == params['hub.verify_token']
end

get "/" do
  "Nothing to see here"
end
