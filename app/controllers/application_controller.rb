class ApplicationController < ActionController::Base
	before_filter :configure_permitted_parameters, if: :devise_controller?
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  #def configure_permitted_parameters
  	#devise_parameter_sanitizer.for(:sign_up) << :first_name
  	#devise_parameter_sanitizer.for(:sign_up) << :last_name
  	#devise_parameter_sanitizer.for(:sign_up) << :profile_name
    #devise_parameter_sanitizer.for(:account_update) << :avatar
  #end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name, :profile_name, :email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name, :profile_name, :avatar, :skype, :email, :password, :password_confirmation)
    end
  end




end
