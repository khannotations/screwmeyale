class UsersController < ApplicationController
  layout "main"
  before_filter CASClient::Frameworks::Rails::Filter

  def auth
    redirect_to :root
  end

  def info
    @user = User.find(session[:user_id])
    if @user
      g = params[:gender].to_i
      p = params[:preference].to_i
      @user.gender = g if (1..2).include? g
      @user.preference = p if (1..3).include? p
      @user.major = params[:major] if params[:major] and params[:major] != ""
      @user.nickname = params[:nickname] if params[:nickname] and params[:nickname] != ""
      @user.active = true
      @user.save
      flash[:success] = "Your preferences were updated. Welcome to Screw Me Yale!"
      render :partial => "main/user_info", :locals => {:u => @user}
      if params[:nickname] and params[:nickname] != ""
        User.make_names
      end
      return
    elsif
      render :json => {:status => "fail", :flash => "Don't mess around!"}
    end
    redirect_to :root
  end

  # Takes a user's name (e.g. Faiaz "Rafi" Khan), parses out the nickname
  # and renders a json of the user. This is necessary because of how the 
  # typeahead works
  def whois
    me = User.find(session[:user_id])
    if not me or not me.active
      render :json => {:status => "inactive"}
      return
    end
    name = params[:name];
    if name != ""
      n = /"(\w|-)+" /.match(name)
      if n
        nickname = n[0][1..(n[0].length-3)] # leaves off starting quote mark, trailing space and trailing quote mark
        name = name.sub(n[0], "").split(" ") # removes nickname
      else
        name = name.split(" ")
      end
      # Now 'name' is an array 
      fname = name[0]
      lname = name[1, 5].join(" ") # the rest

      if !nickname
        @user = User.where(fname: fname, lname: lname).first
      else
        @user = User.where(fname: fname, lname: lname, nickname: nickname).first
      end
      p = {}
      if @user
        p[:name] = @user.fullname
        p[:id] = @user.id
        p[:select] = @user.make_select 
        render :json => {:status => "success", :person => p}
      else # should never happen
        render :json => {:status => "fail", :flash => "No such user >:("}
      end
    else
      render :json => {:status => "fail", :flash => "No parameters"}
    end
  end

end
