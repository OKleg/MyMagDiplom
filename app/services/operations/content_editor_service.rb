module Operations
  class ContentEditorService < ApplicationService
    def initialize(room,transformed_operation)
      @room = room
      @transformed_operation = transformed_operation
    end

    # Применение новой операции к документу
    def call
      # Если операция успешно трансформирована, применяем её
      if @transformed_operation
        Rails.logger.info "operation: #{@transformed_operation.inspect}"
        type = @transformed_operation.input_type
        if type == "deleteContentBackward" || type == "deleteContentForward"
          type = "delete"
        end
        case type
        when 'insertText'
          Rails.logger.info "room: '#{@room.content}'."

          # if @transformed_operation.position <= @room.content.length
          # position =
          #   if @transformed_operation.position>0
          #     @transformed_operation.position-1
          #   else
          #     @transformed_operation.position
          #   end
          @room.content.insert(@transformed_operation.position, @transformed_operation.text)
          # else
          #   @room.content.insert(@room.content.length-1, @transformed_operation.text)
          # end

        when 'delete'
          @room.content.slice!(@transformed_operation.position)
        end
        # @room.version = @room.increment(:version)
        @room.version = @transformed_operation.version
        @room.save!
      end
    end


  end
end
