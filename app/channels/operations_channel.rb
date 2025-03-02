class OperationsChannel < ApplicationCable::Channel


  def subscribed
    Rails.logger.info "Subscribed to room #{params[:id]}"

     stream_from "operation_channel_#{params[:id]}"
  end
  def receive(data)
    # Принимаем изменения от клиента и транслируем их всем подписчикам
    Rails.logger.info "Reseive #{data["status"]}"
    document = Room.find(params[:id])
    new_data = {status: data["status"], user: data["user"], version: document.version}
    if data["status"] == "update_text"
      operation = data["operation"]#
      Operation.create(room:document,
        type: operation["type"],
        text: operation["text"],
        position: operation["position"],
        version: operation["version"]
      )

      operation = operation_transformation(document, data["operation"])
      modified_content = update_text(document.content, operation)
      document.update(content: modified_content)
    elsif data["status"] == "connect_user"
      Rails.logger.info "User #{data["user"]} connected to room_#{params[:id]} "
    end
    new_data["content"] = document.content
    ActionCable.server.broadcast("operation_channel_#{params[:id]}", new_data)
  end


  def unsubscribed
    Rails.logger.info "Unsubscribed from room #{params[:id]}"
    # Any cleanup needed when channel is unsubscribed
  end
  private
  def update_text(content, operation)
    modified_content = content
    if operation["type"] == "insertText" && operation["text"] != ""
      modified_content = modified_content.insert(operation["position"]-1, operation["text"])
    elsif operation["type"] == "deleteContentBackward"
      modified_content.slice!(operation["position"])
    elsif operation["type"] == "deleteContentForward"
      modified_content.slice!(operation["position"])
    end
    content
  end

  def operation_transformation(document,operation)

  end

end
