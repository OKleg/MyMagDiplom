class RoomsController < ApplicationController
  before_action :require_authentication

  def index
    @rooms= Room.public_rooms
    @users = User.all_except(Current.user)
  end
end
