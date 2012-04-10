# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Screwyale::Application.initialize!

require 'casclient'
require 'casclient/frameworks/rails/filter'
CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://secure.its.yale.edu/cas/",
  :username_session_key => :cas_user
)