class MainController < ActionController::Base
  layout "application"

  # Checks for session[:cas_user]; renders splash if not set.
  # Otherwise renders main page, after fetching required data.
  def index
    if session[:cas_user]
      @user = User.find_by_netid(session[:cas_user])
      # Test users:
      # @user = User.find_by_email("hanmyo.oo@yale.edu")
      # session[:cas_user] = ""
      # @user = User.find_by_email("derwin.aikens@yale.edu")

      if not @user
        @user = User.get_user(session[:cas_user])
        if not @user
          session[:cas_user] = nil
          flash[:error] = "Sorry, but this app only works for Yale undergrads listed on the Yale Face Book. \
          If you'd like to be added, contact Rafi!"
          redirect_to :root
          return
        end
      end
      session[:user_id] = @user.id
      # Didn't use @user.screws because there'd be a where clause anyway
      @screws = Screwconnector.includes(:screw).where(screwer_id: @user.id, match_id: 0)
      # a.k.a @user.screwers.includes...where(match_id: 0)
      @screwers = Screwconnector.includes(:screwer).where(screw_id: @user.id, match_id: 0)
      @sent_requests = @user.get_sent
      @got_requests = @user.get_got
      @sent_past = @user.get_past_sent
      @got_past = @user.get_past_got
      @history = @user.history  # not rendered as of now
      render "show", :layout => "main"
      return
    end
  end

  def about
    render "about", :layout => "main"
  end

  # Gets a list of all the users, minus yourself (for the typeahead)
  # Done as a seperate request to speed up initial page load
  def all
    if session[:user_id]
      u = User.find(session[:user_id])
      students = User.all_names.clone
      students.delete(u.lengthy_name)
      render :json => students
      return
    end
    render :nothing => true
  end
  
  def logout
    session[:user_id] = nil
    session[:cas_user] = nil
    flash[:success] = "See you again soon!!"
    redirect_to :root
  end

  def google
    render "google", :layout => false
  end

  def uncas
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end