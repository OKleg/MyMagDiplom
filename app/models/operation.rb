class Operation < ApplicationRecord
  # after_create :transform
  belongs_to :document_version

  private

  def transform(room)
    Rails.logger.info "Operation transform #{self}"
    Rails.logger.info "Operation transform room #{document_version.room.name}"
    # theirs = Operation.where(version >= :version)
    # right, bottom = TransformationService.call(theirs, self)

    # room = document_version.room

    # Получаем последнюю версию документа
    current_version = room.document_versions.last

    # Трансформируем новую операцию относительно всех операций в текущей версии
    transformed_operation = Operation::TransformationService.call(
      new_operation: self,
      current_version_operations: current_version.operations
    )

    if transformed_operation
      # Создаем новую версию документа
      new_version = room.document_versions.create!(
        version_number: current_version.version_number + 1
      )
       # Сохраняем операцию
       new_version.operations.create!(
        type: transformed_operation.type,
        position: transformed_operation.position,
        text: transformed_operation.text,
        version: transformed_operation.version
      )
    end
    transformed_operation
  end

end
