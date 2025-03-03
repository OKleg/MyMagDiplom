class OperationsChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "Subscribed to room #{params[:id]}"
     stream_from "operation_channel_#{params[:id]}"
  end

  def receive(data)
    # Принимаем изменения от клиента и транслируем их всем подписчикам
    Rails.logger.info "RESIVE data: #{data}"
    room = Room.find(params[:id])
    new_data = {status: data["status"], user: data["user"], version: room.version}

    if data["status"] == "update_text"
      operation = data["operation"]
      new_operation = Operation.new(
        type: operation["type"],
        text: operation["text"],
        position: operation["position"],
        version: operation["version"]
      )
      transformed_operation = new_operation.transform(room)
      Operation::RoomEditorService.call(room, transformed_operation)
      if new_version
        ActionCable.server.broadcast("operation_channel_#{params[:id]}", new_data)
      end
      # operation = operation_transformation(room, data["operation"])
      # modified_content = update_text(room.content, operation)
      # room.update(content: modified_content)
    elsif data["status"] == "connect_user"
      Rails.logger.info "User #{data["user"]} connected to room_#{params[:id]} "
      ActionCable.server.broadcast("operation_channel_#{params[:id]}", new_data)
    end
    new_data["content"] = room.content
    # ActionCable.server.broadcast("operation_channel_#{params[:id]}", new_data)
  end

  def unsubscribed
    Rails.logger.info "Unsubscribed from room #{params[:id]}"
    # Any cleanup needed when channel is unsubscribed
  end

  private

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

  # def operation_transformation(room,operation)

  # end

end
