require 'facebook/messenger'
require 'httparty'
require 'json'
include Facebook::Messenger
# NOTE: ENV variables should be set directly in terminal for localhost

# IMPORTANT! Subcribe your bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])

API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?address='.freeze

IDIOMS = {
  not_found: 'There were no resutls. Ask me again, please',
  ask_location: 'Enter destination'
}.freeze

def wait_for_user_input
  Bot.on :message do |message|
    case message.text
    when /coord/i, /gps/i # we use regexp to match parts of strings
      message.reply(text: IDIOMS[:ask_location])
      process_coordinates
    when /full ad/i # we got the user even if he misspells address
      message.reply(text: IDIOMS[:ask_location])
      show_full_address
    end
  end
end

def process_coordinates
  handle_api_request do |api_response, message|
    coord = extract_coordinates(api_response)
    message.reply(text: "Latitude: #{coord['lat']} / Longitude: #{coord['lng']}")
  end
end

def show_full_address
  handle_api_request do |api_response, message|
    full_address = extract_full_address(api_response)
    message.reply(text: full_address)
  end
end

def handle_api_request
  Bot.on :message do |message|
    puts "Received '#{message.inspect}' from #{message.sender}" # for development only
    parsed_response = get_parsed_response(API_URL, message.text)
    unless parsed_response
      message.reply(text: IDIOMS[:not_found])
      wait_for_user_input
      return
    end
    message.typing_on # let user know we're doing something
    yield(parsed_response, message)
    wait_for_user_input
  end
end

# Talk to API
def get_parsed_response(url, query)
  response = HTTParty.get(url + query)
  parsed = JSON.parse(response.body)
  parsed['status'] != 'ZERO_RESULTS' ? parsed : nil
end

def extract_coordinates(parsed)
  parsed['results'].first['geometry']['location']
end


def extract_full_address(parsed)
  parsed['results'].first['formatted_address']
end

# launch the loop
wait_for_user_input