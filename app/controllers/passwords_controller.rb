class PasswordsController < ApplicationController
  before_action :require_authentication

  def edit
  end

  def update
    if Current.user.update(password_params)
      redirect_to dashboard_path, notice: "Password updated"
    else
      flash.now[:notice] = Current.user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params
      .require(:password)
      .permit(:password, :password_confirmation, :password_challenge)
      .with_defaults(password_challenge: "") # This line is important!
  end
end
