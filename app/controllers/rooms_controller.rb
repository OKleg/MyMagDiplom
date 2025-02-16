class RoomsController < ApplicationController
  before_action :require_authentication

  def index
    @single_room = Room.take
    @rooms = Room.new
    @rooms= Room.public_rooms
    @users = User.all_except(Current.user)
  end

  def show
    @single_room = Room.find(params[:id])
    @rooms = Room.new
    @rooms= Room.public_rooms
    @users = User.all_except(Current.user)
    render 'index'
  end

  def create
    # @room = Room.create(name: params["room"]["name"])
    @room = Room.create(name: params["name"])
  end
end
