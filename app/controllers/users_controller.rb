class UsersController < ApplicationController
  before_action :restore_authentication
  def show
    redirect_to dashboard_path
  end
end
