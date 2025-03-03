module Operation
  class RoomEditorService < ApplicationService
    def initialize(room)
      @room = room
    end

    # Применение новой операции к документу
    def call(transformed_operation)
      # # Получаем последнюю версию документа
      # current_version = @room.document_versions.last

      # # Трансформируем новую операцию относительно всех операций в текущей версии
      # current_version.operations.each do |existing_operation|
      #   new_operation = new_operation.transform(existing_operation)
      #   break if new_operation.nil? # Конфликт
      # end

      # Если операция успешно трансформирована, применяем её
      if transformed_operation
        # # Создаем новую версию документа
        # new_version = @room.document_versions.create!(
        #   version_number: current_version.version_number + 1
        # )

        # Применяем операцию к новой версии
        type = transformed_operation.type.dup
        if type == "deleteContentBackward" || type == "deleteContentForward"
          type = "delete"
        end
        case type
        when 'insertText'
          room.content.insert(transformed_operation.position, transformed_operation.text)
        when 'delete'
          room.content.slice!(transformed_operation.position)
        end
        room.save!

        # # Сохраняем операцию
        # new_version.operations.create!(
        #   type: new_operation.type,
        #   position: new_operation.position,
        #   text: new_operation.text,
        #   version: new_operation.version
        # )
      end
    end


  end
end
