class GetFriendsController < ApplicationController
  def show

  	@user = User.all.sample
  	if @user
  		
  		render action: :show
  	else
  	render file: 'public/404', status: 404, formats: [:html]
  	end
  end


end