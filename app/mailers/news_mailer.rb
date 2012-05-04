class NewsMailer < ActionMailer::Base
  include SendGrid
  default from: "mailman@screwmeyale.com"

  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  def welcome_message(user, screwer)
    @user = user
    @screwer = screwer
    sendgrid_category "Welcome"
    mail :to => user.email, :subject => "You've been screwed!"
    puts "\n\n\nEmail sent to #{user.email} with #{screwer.fullname}\n\n\n"
  end

  def goodbye_message(user)
    sendgrid_disable :ganalytics
    mail :to => user.email, :subject => "Fare thee well :-("
  end
end
