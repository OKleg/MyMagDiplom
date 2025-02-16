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
      data = operation_transformation(document.version, data)
      modified_content = update_text(document.content, data)
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
  def update_text(content, data)
    modified_content = content
    if data["inputType"] == "insertText" && data["content"] != ""
      modified_content = modified_content.insert(data["position"]-1, data["conent"])
    elsif data["inputType"] == "deleteContentBackward"
      modified_content.slice!(data["position"])
    elsif data["inputType"] == "deleteContentForward"
      modified_content.slice!(data["position"])
    end
    content
  end

  def operation_transformation(content_version,data)
    data
  end

end
