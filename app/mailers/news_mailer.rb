class NewsMailer < ActionMailer::Base
  include SendGrid

  default from: "mailman@screwmeyale.com"

  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  # sc is screwconnector object, to is the full name to go in the "to" field and view is hte view to render
  def screw_mail(sc, to, view)
    @screw = sc.screw
    @screwer = sc.screwer
    @event = sc.event

    cat = view.gsub("/_/", " ").titlecase
    sendgrid_category cat
    # Sendgrid gem wasn't working for some reason, so posting manually.
    # Get the body of the email to send.
    body = render_to_string :action => view, :layout => false
    
    client = HTTPClient.new # New HTTP client

    # to will be to.email
    params = {:to => "faiaz.khan@yale.edu", :toname => to.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"
    res = client.post(url, :body => params)

    return true if res.body == "{\"message\":\"success\"}"
    return false
  end

  def new_request(r)
    @from = r.from.screw # This is the request's creator's screw
    @to = r.to.screwer # this is who the email is to
    @for = r.to.screw # Who does the person want to set up?
    @event = r.from.event # 

    sendgrid_category "New Request"
    # Sendgrid gem wasn't working for some reason, so posting manually.
    # Get the body of the email to send.
    body = render_to_string :action => "new_request", :layout => false
    
    client = HTTPClient.new # New HTTP client

    # to will be @to.email
    params = {:to => "faiaz.khan@yale.edu", :toname => @to.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"
    res = client.post(url, :body => params)

    return true if res.body == "{\"message\":\"success\"}"
    return false
  end

  def request_accepted(r)
    @from = r.from.screw # This is the request's creator's screw
    @to = r.to.screwer # this is who the email is to
    @for = r.to.screw # Who does the person want to set up?
    @event = r.from.event # 

    sendgrid_category "New Request"
    # Sendgrid gem wasn't working for some reason, so posting manually.
    # Get the body of the email to send.
    body = render_to_string :action => "new_request", :layout => false
    
    client = HTTPClient.new # New HTTP client

    # to will be @to.email
    params = {:to => "faiaz.khan@yale.edu", :toname => @to.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"
    res = client.post(url, :body => params)

    return true if res.body == "{\"message\":\"success\"}"
    return false
  end


  # def new_screw(sc)
  #   @screw = sc.screw
  #   @screwer = sc.screwer
  #   @event = sc.event

  #   sendgrid_category "New Screw"
  #   # Sendgrid gem wasn't working for some reason, so posting manually.
  #   # Get the body of the email to send.
  #   body = render_to_string :action => "new_screw", :layout => false
    
  #   client = HTTPClient.new # New HTTP client

  #   # The params @screw.email
  #   params = {:to => "faiaz.khan@yale.edu", :toname => @screw.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
  #   url = "https://sendgrid.com/api/mail.send.json"
  #   res = client.post(url, :body => params)

  #   return true if res.body == "{\"message\":\"success\"}"
  #   return false
  # end

  # def unwanted_screwer(sc)
  #   @screw = sc.screw
  #   @screwer = sc.screwer
  #   @event = sc.event

  #   sendgrid_category "Unwanted Screwer"

  #   body = render_to_string :action => "unwanted_screwer", :layout => false

  #   client = HTTPClient.new # New HTTP client
  #   params = {:to => "faiaz.khan@yale.edu", :toname => @screwer.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "Your help was unwanted", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
  #   url = "https://sendgrid.com/api/mail.send.json"
  #   res = client.post(url, :body => params)
  #   return true if res.body == "{\"message\":\"success\"}"
  #   return false
  # end

  def goodbye_message(user)
    sendgrid_disable :ganalytics
    mail :to => user.email, :subject => "Fare thee well :-("
  end
end
