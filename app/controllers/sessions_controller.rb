class SessionsController < ApplicationController
  require 'omniauth-facebook'
  require 'omniauth-twitter'
  require 'omniauth-identity'
  def create
    @user = User.where(auth_hash).first_or_create
    session[:user_id] = @user.id
    redirect_to '/'
  end

  def destroy
    if current_user
      session.delete(:user_id)
      flash[:success] = "Sucessfully logged out!"
    end
    redirect_to root_path
  end

  protected
 
  def auth_hash
    request.env['omniauth.auth']
  end
end