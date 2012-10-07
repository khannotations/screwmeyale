class ScrewconnectorsController < ApplicationController
  layout "main"

  before_filter CASClient::Frameworks::Rails::Filter, :except => [:show]
  
  def show
    @user = User.find(session[:user_id])
    @sc = Screwconnector.includes(:screw, :screwer).where(id: params[:id]).first
    if not @user or not @sc or not @sc.screwer == @user
      logger.error "SHOW", @user.inspect, @sc.inspect, "\n\n\n\n\n"
      flash[:error] = "Sorry, you can't access that url."
      redirect_to :root
      return 
    end

    everything = @sc.find_everything
    @all_screws = everything[0]
    @int_matches = everything[1] # Matches by similar intensity
    @event_matches = everything[2] # Matches by same event
    @all_matches = everything[3] # All users that are matches
    
  end

  def create
    user_id = session[:user_id]
    # Instead of using @user.screws to avoid retrieving user
    count = Screwconnector.where(screwer_id: user_id, match_id: 0).count
    if count >= 5
      render :json => {:status => "fail", :flash => "Sorry, you can only screw up to five people simultaneously. Match one of them first and try again."}
      return
    end
    sc = Screwconnector.includes(:screw).where(
      screw_id: params[:screw_id],
      event: params[:event]
      ).first
    if sc
      if sc.match_id == 0 # Already matched
        puts "\n\n\n\nin sc!\n\n\n\n\n"
        render :json => {:status => "fail", :flash => "Someone is already screwing #{sc.screw.nickname} for #{sc.event}...better be quicker next time!"}
        
      elsif sc.screwer_id == user_id
        render :json => {:status => "fail", :flash => "You're already screwing #{sc.screw.nickname} for #{sc.event}!"}
      end
      return
    end
    sc = Screwconnector.create(
      screw_id: params[:screw_id], 
      screwer_id: user_id, 
      intensity: params[:intensity],
      event: params[:event]
    )
    if sc.errors.messages.empty?
      # Email new screw!
      if NewsMailer.new_screw(sc)
        render :partial => "screwconnectors/main", :locals => {:sc => sc}
      else
        sc.destroy # destroy the screw if emails aren't working
        render :json => {:status => "fail", :flash => "There's was an email problem--please contact the web admin."}
        logger.error "\n\nNew screw email not sent!!\n\n" 
      end
      return
    end
    render :json => {:status => "fail", :flash => sc.errors.messages}

  end

  def destroy

    sc = Screwconnector.find(params[:sc_id]).destroy
    if sc
      if params[:initiator] == "screw"
        # Send warning-ish email to screwer
        logger.error "\n\nUnwanted screwer mail not sent!!\n\n" if not NewsMailer.unwanted_screwer(sc)
        render :json => {:status => "success", :flash => "Yeah! You don't need that kinda drama."}
      else
        flash[:success] = "Yeah! You don't need 'em anyway!"
        # email not necessary
        render :json => {:status => "success"} # triggers page reload
      end
    else 
      render :json => {:status => "fail", :flash => "You tryna mess with me??"}
    end
  end

  def info
    @user = User.find(params[:id])
    if not @user
      render :json => {:status => "fail", :flash => "This person doesn't exist...please stop messing around"}
    end
    if @user.id == session[:user_id] or not @user.active
      g = params[:gender].to_i
      p = params[:preference].to_i
      @user.gender = g if (1..2).include? g
      @user.preference = p if (1..3).include? p
      @user.major = params[:major] if params[:major] and params[:major] != ""
      @user.nickname = params[:nickname].gsub(/\s/, "") if params[:nickname] and params[:nickname] != ""
      @user.save
      flash[:success] = "Preferences updated...now get matching!"
      render :json => {:status => "success"} # triggers page reload
      if params[:nickname] and params[:nickname] != ""
        User.make_names
      end
      return
    else
      render :json => {:status => "fail", :flash => "Stop screwing around"}
    end
  end

end
