class RequestsController < ApplicationController

  def create
    # Check to make sure no request from 'from' to 'to' exists
    r = Request.where(to_id: params[:to], from_id: params[:from]).first
    if r
      render :json => {:status => "fail", :flash => "You've already sent a request to this person! Perhaps it was rejected? :("}
      return
    end
    r = Request.new(to_id: params[:to], from_id: params[:from])
    if r.save

      logger.error "\n\nNew request email not sent!!\n\n" if not NewsMailer.new_request(r)      
      render :json => {:status => "success", :flash => "You've sent out a new request! We'll email you when that cutie's screwer accepts ;)"}

    else
      render :json => {:status => "fail", :flash => "Please stop messing around"}
    end
  end

  # Not the same as denying a request -- this is when the sender cancels
  def delete
    r = Request.find(params[:r_id])
    if r
      r.destroy
      render :json => {:status => "success", :flash => "Guess they weren't the one after all :-/"}
    else
      render :json => {:status => "fail", :flash => "Please stop messing around"}
    end
  end

  # aka REJECTION
  def deny
    r = Request.find(params[:r_id])
    if r
      r.accepted = false
      r.save
      render :json => {:status => "success", :flash => "Damn...you harsh!"}
    else
      render :json => {:status => "fail", :flash => "Please stop messing around"}
    end
  end

  def accept
    r = Request.includes({:to => :screw}, {:from => :screw}).find(params[:r_id])
    if r
      to = r.to # my screw
      from = r.from # the sending screw
      if from.match_id == 0 and to.match_id == 0 
      # if both screws are still unmatched
        r.accepted = true
        r.save
        to = r.to # my screw
        from = r.from # the sending screw

        from.match_id = to._id
        from.save

        logger.error "\n\nRequest accepted email not sent!!\n\n" if not NewsMailer.request_accepted(r)
        
        if to.event == from.event # If they're going to the same event, block both
          to.match_id = from.id
          to.save
          to.cleanup # delete all pending requests, etc
          # Mail will be handled by request_accepted
        end
        from.cleanup
        flash[:success] = "Congrats, you've successfully screwed #{to.screw.nickname} with #{from.screw.fullname} for #{from.event.upcase}! Check your email to find out who the other screwer is!"
        render :json => {:status => "success"} # will trigger a page redirect
      else
        render :json => {:status => "fail", :flash => "Sorry, you took too long! Someone else already matched with #{from.screw.nickname} :("}
      end
    else
      render :json => {:status => "fail", :flash => "Sorry, that request was cancelled!"}
    end
  end
end
