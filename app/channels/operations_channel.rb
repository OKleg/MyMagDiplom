class OperationsChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "__________________ "
    Rails.logger.info "OperationsChannel "
    Rails.logger.info "ApplicationCable::Channel "
    Rails.logger.info "User #{params[:user_id]} connected to room_#{params[:room_id]}"
    Rails.logger.info "Subscribed to room #{params[:room_id]}"
    stream_from "operation_channel_#{params[:room_id]}"
  end

  def receive(data)
    Rails.logger.info "__________________ "
    Rails.logger.info "OperationsChannel "
    Rails.logger.info "ApplicationCable::Channel "

    # Принимаем изменения от клиента и транслируем их всем подписчикам
    Rails.logger.info "RESIVE data: #{data}"
    if data["status"] == "update_text"
      Rails.logger.info "OperationsChannel recive update_text "
      TransformationJob.perform_later(data: data)
    elsif data["status"] == "connect_user"
      Rails.logger.info "OperationsChannel recive connect_user "
      connect_user
    end
    # ActionCable.server.broadcast("operation_channel_#{params[:room_id]}", new_data)
  end

  def unsubscribed
    # Rails.logger.info "Unsubscribed from room #{params[:room_id]}"
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def connect_user
    room_id = params[:room_id]
    room = Room.find(room_id)
    user = User.find(params[:user_id])
    connect_data = { status: "connect_user", content: room.content,
      user: { id: user.id, email: user.email }, version: room.version }
    # Rails.logger.info "User #{user.email} connected to room_#{room_id} "
    ActionCable.server.broadcast("operation_channel_#{room_id}", connect_data)
  end
  # def room_id_params
  #   params.require(:room_id)
  # end

  # def update_text(content, operation)
  #   modified_content = content
  #   if operation["type"] == "insertText" && operation["text"] != ""
  #     modified_content = modified_content.insert(operation["position"]-1, operation["text"])
  #   elsif operation["type"] == "deleteContentBackward"
  #     modified_content.slice!(operation["position"])
  #   elsif operation["type"] == "deleteContentForward"
  #     modified_content.slice!(operation["position"])
  #   end
  #   content
  # end


end
