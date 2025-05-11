class RegistrationsController < ApplicationController
  before_action :redirect_if_signed_in, only: %i[new create]

  def new
    puts "RegistrationsController New "

    @user = User.new
  end

  def create
    @user = User.new(user_params)
    puts "RegistrationsController Create "

    if @user.save
      put "Add New User"
      sign_in @user
      redirect_to dashboard_path, notice: "You have successfully registered!"
    else
      put " New User unsafe"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
