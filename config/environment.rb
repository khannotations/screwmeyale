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

ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => "smtp.sendgrid.net",
  :port => 25,
  :domain => "screwmeyale.com",
  :authentication => :plain,
  :user_name => "fizzcan",
  :password => "screwmeyale"
}

ENV['CAS_PASS'] = "910qTuP0448"