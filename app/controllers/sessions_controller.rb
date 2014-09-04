class SessionsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      sign_in @user
      flash[:success] = "Welcome"
      redirect_to user_path(@user)
    else
      flash.now[:error] = "Invalid credentails!"
      render 'new'
    end

  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
