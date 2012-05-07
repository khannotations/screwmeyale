class NewsMailer < ActionMailer::Base
  include SendGrid

  default from: "mailman@screwmeyale.com"

  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  def welcome_message(sc)
    @screw = sc.screw
    @screwer = sc.screwer
    @event = sc.event

    sendgrid_category "Welcome"
    # Sendgrid gem wasn't working for some reason, so posting manually.
    # Get the body of the email to send.
    body = render_to_string :action => "welcome_message", :layout => false
    
    client = HTTPClient.new # New HTTP client

    # The params @screw.email
    params = {:to => "faiaz.khan@yale.edu", :toname => @screw.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"
    res = client.post(url, :body => params)

    return true if res.body == "{\"message\":\"success\"}"
    return false
  end

  def goodbye_message(user)
    sendgrid_disable :ganalytics
    mail :to => user.email, :subject => "Fare thee well :-("
  end
end
