class MainController < ActionController::Base
  layout "application"

  # Checks for session[:cas_user]; renders splash if not set.
  # Otherwise renders main page, after fetching required data.
  def index
    if session[:cas_user]
      @user = User.find_by_netid(session[:cas_user])
      # @user = User.find_by_email("derwin.aikens@yale.edu")
      if not @user
        @user = User.ldap(session[:cas_user])
        if not @user
          session[:cas_user] = nil
          flash[:error] = "Sorry, but this app is only for Yale undergrads."
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
      @history = @user.history  # not rendered as of now
      render "show", :layout => "main"
      return
    end
  end

  def about
    render "about", :layout => "main"
  end

  # Gets a list of all the users, minus yourself (for the typeahead)
  def all
    if session[:user_id]
      u = User.find(session[:user_id])
      students = User.all_names.clone
      students.delete(u.fullname)
      render :json => students
      return
    end
    render :nothing => true
  end
  
  def logout
    session[:user_id] = nil
    session[:cas_user] = nil
    flash[:success] = "Successfully logged out."
    redirect_to :root
  end

  def uncas
    puts "\n\n\n\n\n\n", "UNCASSED"
    CASClient::Frameworks::Rails::Filter.logout(self)
    #render :text => "true"
  end

end