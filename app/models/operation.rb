class Operation < ApplicationRecord
  belongs_to :room
  belongs_to :user
  # after_commit :broadcast_operation

  def transform(transform_service: Operations::TransformationService, content_edit_service: Operations::ContentEditorService)
    Rails.logger.info "Operation transform #{self.to_s}"
    # Получаем операции до последней версии документа
    #       "user_id <> :current_user_id AND version BETWEEN  :operation_version AND :current_version", {
    current_version_operations = Operation.where(
      "room_id = :current_room AND version > :operation_version", {
        current_room:  self.room_id,
      current_user_id: self.user_id,
        operation_version: self.version.to_s}
      ).order(version: :desc)
    # Трансформируем новую операцию относительно всех операций в текущей версии
    Rails.logger.info "transform_service.call"
    transformed_operation = transform_service.call(
       self,
       current_version_operations.to_a
    )
    # Если операция успешно трансформирована, сохраняем и применяем её
    if transformed_operation
      Rails.logger.info "transformed_operation: #{transformed_operation.inspect}"
      transformed_operation.version = self.room.version+1
      if transformed_operation.save!
        content_edit_service.call(self.room, transformed_operation)
        ActionCable.server.broadcast("operation_channel_#{self.room.id}",{status: "update_text", operation: self})
      end
    end
  end
end
