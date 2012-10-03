class NewsMailer < ActionMailer::Base
  include SendGrid

  default from: "mailman@screwmeyale.com"

  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  # sc is screwconnector object, to is the full name to go in the "to" field and view is hte view to render
  # view is either "new_screw" or "unwanted_screwer"
  def screw_mail(sc, to, view)
    acceptable_views = %w(new_screw unwanted_screwer)
    raise "Unknown view #{view}" if not acceptable_views.include? view
    @screw = sc.screw
    @screwer = sc.screwer
    @event = sc.event

    # Make category from view
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

  # Email sent when a new request is generated
  def new_request(r)
    # @from = r.from.screwer # This is the request's creator, SHOULD NOT BE MENTIONED IN THIS EMAIL EVER
    @from_screw = r.from.screw # This is the request's creator's screw
    @to = r.to.screwer # this is who the email is to
    @to_screw = r.to.screw # Who does the person want to set up?
    @event = r.from.event # 
    @to_event = r.to.event
    @same_event = (@event == @to_event)

    sendgrid_category "New Request"

    body = render_to_string :action => "new_request", :layout => false
    
    client = HTTPClient.new # New HTTP client

    # to will be @to.email
    params = {:to => "faiaz.khan@yale.edu", :toname => @to.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"
    res = client.post(url, :body => params)

    return true if res.body == "{\"message\":\"success\"}"
    return false
  end

  # When someone accepts a screw, there are two emails sent, one to each screwer, revealing the other's identity.
  # There is a special case when they're going to the same event, which is handled.
  def request_accepted(r)
    @from = r.from.screwer # This is the request's creator
    @from_screw = r.from.screw # This is that person's screw
    @to = r.to.screwer # This is who accepted the screw / who the email is to
    @to_screw = r.to.screw # This is that person's screw
    @event = r.from.event # IT MUST THE BE THE EVENT FOR THE 'FROM' !! (if same_event is true, this doesn't matter)
    @to_event = r.to.event

    @same_event = (@event == @to_event)

    sendgrid_category "Request Accepted"

    body_from = render_to_string :action => "request_accepted_from", :layout => false
    body_to = render_to_string :action => "request_accepted_to", :layout => false
    
    client = HTTPClient.new # New HTTP client

    # to will be @from.email
    params_from = {:to => "faiaz.khan@yale.edu", :toname => @from.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body_from}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    # to will be @to.email
    params_to = {:to => "faiaz.khan@yale.edu", :toname => @to.fullname, :from => "mailman@screwmeyale.com", :fromname => "Yale Screw", :subject => "You've been screwed!", :html => "#{body_to}", :api_user => "fizzcan", :api_key => "screwmeyale"}
    url = "https://sendgrid.com/api/mail.send.json"

    res_from = client.post(url, :body => params_from)
    res_to = client.post(url, :body => params_to)

    return true if res_from.body == "{\"message\":\"success\"}" and res_to.body == "{\"message\":\"success\"}"
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
