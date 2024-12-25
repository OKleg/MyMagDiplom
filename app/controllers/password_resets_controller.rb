
class PasswordResetsController < ApplicationController
  before_action :redirect_if_signed_in

  def new
  end

  def create
    if user = User.find_by(email: params[:email])
      token = user.generate_token_for(:password_reset)
      UserMailer.with(user: user, password_reset_token: token).password_reset.deliver_later

      redirect_to root_path, notice: "Email sent with password reset instructions"
    else
      flash.now[:notice] = "No user found with that email address"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    user = User.find_by_token_for(:password_reset, params[:password_reset_token])

    if user.nil?
      flash[:notice] = "Invalid token. Try again by requesting a new password reset link."
      redirect_to new_password_reset_path
    elsif user.update(password_reset_params)
      sign_in user
      redirect_to dashboard_path, notice: "Password has been successfully reset"
    else
      flash.now[:notice] = user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_reset_params
    params.require(:password_reset).permit(:password, :password_confirmation)
  end
end
