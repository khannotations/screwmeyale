class ScrewconnectorsController < ApplicationController
  layout "main"

  before_filter CASClient::Frameworks::Rails::Filter, :except => [:show]
  
  def show
    @user = User.find(session[:user_id])
    @sc = Screwconnector.includes(:screw, :screwer).where(id: params[:id]).first
    if not @user or not @sc or not @sc.screwer == @user
      puts "SHOW", @user.inspect, @sc.inspect, "\n\n\n\n\n"
      flash[:error] = "Sorry, you can't access that url."
      redirect_to :root
      return 
    end

    @all_screws = @sc.find_all_screws # All screwconnectors that are matches
    @all_matches = @sc.find_all_matches # All users that are matches
    @int_matches = @sc.find_int # Matches by similar intensity
    @event_matches = @sc.find_event # Matches by same event
    
  end

  def create
    user_id = session[:user_id]
    # Instead of using @user.screws to avoid retrieving user
    count = Screwconnector.where(screwer_id: user_id, match_id: 0).count
    if count >= 5
      render :json => {:status => "fail", :flash => "Sorry, you can only screw up to five people simultaneously. Match one of them first and try again."}
      return
    end
    sc = Screwconnector.where(
      screw_id: params[:screw_id],
      event: params[:event]
      ).first
    if sc
      if sc.match_id != 0 # Already matched
        render :json => {:status => "fail", :flash => "Someone has already screwed #{sc.screw.nickname} for #{sc.event}...better be quicker next time!"}
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
      render :partial => "screwconnectors/main", :locals => {:sc => sc}
      return
    end
    render :json => {:status => "fail", :flash => sc.errors.messages}

  end

  def destroy
    begin
      Screwconnector.find(params[:sc_id]).destroy
      if params[:initiator] == "screw"
        render :json => {:status => "success", :flash => "Yeah! You don't need that kinda drama."}
      else
        flash[:success] = "Yeah! You don't need 'em anyway!"
        render :json => {:status => "success"} # triggers page redirect
      end

    rescue
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
      @user.nickname = params[:nickname] if params[:nickname] and params[:nickname] != ""
      @user.save
      p @user
    end
    flash[:success] = "Preferences updated...now get matching!"
    render :json => {:status => "success"}
  end

end
