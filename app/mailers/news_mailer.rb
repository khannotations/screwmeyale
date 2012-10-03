class NewsMailer < ActionMailer::Base
  ME = "faiaz.khan@yale.edu"
  
  include SendGrid

  default from: "mailman@screwmeyale.com"
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  # sc is screwconnector object, to is the full name to go in the "to" field and view is the view to render
  # view is either "new_screw" or "unwanted_screwer"
  def new_screw(sc)
    sendgrid_category "New Screw"

    @screw = sc.screw
    @screwer = sc.screwer
    @event = sc.event

    subject = "You've been screwed!"

    body = render_to_string :action => "new_screw", :layout => false

    NewsMailer.mail(@screw.email, @screw.fullname, subject, body)

  end

  def unwanted_screwer(sc, to, view)
    sendgrid_category "Unwanted Screwer"

    @screw = sc.screw
    @screwer = sc.screwer
    @event = sc.event

    subject = "Some sour news"

    body = render_to_string :action => "unwanted_screwer", :layout => false
    NewsMailer.mail(@screwer.email, @screwer.fullname, subject, body)

  end

  # Email sent when a new request is generated
  def new_request(r)
    sendgrid_category "New Request"

    @from_screw = r.from.screw # This is the request's creator's screw
    @to = r.to.screwer # this is who the email is to
    @to_screw = r.to.screw # Who does the person want to set up?
    @event = r.from.event # The actual event
    @to_event = r.to.event # The other event 
    @same_event = (@event == @to_event)

    body = render_to_string :action => "new_request", :layout => false
    subject = "A New Request!"

    NewsMailer.mail(@to.email, @to.fullname, subject, body)
  end

  # When someone accepts a screw, there are two emails sent, one to each screwer, revealing the other's identity.
  # There is a special case when they're going to the same event, which is handled.
  def request_accepted(r)
    sendgrid_category "Request Accepted"

    @from = r.from.screwer # This is the request's creator
    @from_screw = r.from.screw # This is that person's screw
    @to = r.to.screwer # This is who accepted the screw / who the email is to
    @to_screw = r.to.screw # This is that person's screw
    @event = r.from.event # IT MUST THE BE THE EVENT FOR THE 'FROM' !! (if same_event is true, this doesn't matter)
    @to_event = r.to.event

    @same_event = (@event == @to_event)

    body_from = render_to_string :action => "request_accepted_from", :layout => false
    subject_from = "Your request has been accepted!"

    body_to = render_to_string :action => "request_accepted_to", :layout => false
    subject_to = "You just accepted a request!"
    
    result_from = NewsMailer.mail(@from.email, @from.fullname, subject_from, body_from)
    result_to = NewsMailer.mail(@to.email, @to.fullname, subject_to, body_to)

    return (result_from and result_to)
  end

  # Sendgrid gem wasn't working for some reason, so posting manually.
  # returns true or false
  def NewsMailer.mail(to_email, to_name, subject, html)
    client = HTTPClient.new # New HTTP client

    # :to will be to_email
    params = {:to => ME, :toname => to_name, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => subject, :html => html, :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"
    puts "putting client"
    p client
    res = client.post(url, :body => params)
    puts "success!"
    return (res.body == "{\"message\":\"success\"}")
  end

  def goodbye_message(user)
    sendgrid_disable :ganalytics
    mail :to => user.email, :subject => "Fare thee well :-("
  end
end
