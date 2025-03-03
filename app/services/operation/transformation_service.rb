module Operation
  class TransformationService < ApplicationService
    def initialize(new_operation:)
      @operation = new_operation
    end

    def call(current_version_operations:) #current_version_operations
      # Трансформируем новую операцию относительно всех операций в текущей версии
      current_version_operations.each do |existing_operation|
        new_operation = transform(other: existing_operation)
        break if new_operation.nil? # Конфликт
      end
    end

    # Трансформация текущей операции относительно другой операции
    def transform(other:)
      # insertText deleteContentBackward deleteContentForward
      type = @operation.type.dup
      if type == "deleteContentBackward" || type == "deleteContentForward"
        type = "delete"
      end
      other_type = other.type
      if other_type == "deleteContentBackward" || other_type == "deleteContentForward"
        other_type = "delete"
      end
      case [type, other_type]
      when ['insertText', 'insertText']
        transform_insert_insert(other)
      when ['insertText', 'delete']
        transform_insert_delete(other)
      when ['delete', 'insertText']
        transform_delete_insert(other)
      when ['delete', 'delete']
        transform_delete_delete(other)
      else
        @operation
      end
    end

    private

    def transform_insert_insert(other)
      if @operation.position < other.position
        @operation
      else
        Operation.new(type: @operation.type, position: @operation.position + other.text.length, text: @operation.text, version: @operation.version)
        # @operation.position = @operation.position + other.text.length
        # @operation
      end
    end

    def transform_insert_delete(other)
      if @operation.position <= other.position
        @operation
      else
        Operation.new(type: @operation.type, position: @operation.position - 1, text: @operation.text, version: @operation.version)
      end
    end

    def transform_delete_insert(other)
      if @operation.position < other.position
        @operation
      else
        Operation.new(type: @operation.type, position: @operation.position + other.text.length, text: @operation.text, version: @operation.version)
      end
    end

    def transform_delete_delete(other)
      if @operation.position < other.position
        @operation
      elsif @operation.position > other.position + 1 #other.text.length
        Operation.new(type: @operation.type, position: @operation.position - other.text.length, text: @operation.text, version: @operation.version)
      else
        nil # Конфликт
      end
    end
    # def initialize(others:, ours: )
    #   @left = others
    #   @top = ours
    # end

    # def transform_operation(ours, theirs, win_tiebreakers)
    #   # TODO: handle other kinds of operations

    #   transformed_op = ours.dup

    #   if ours[:position] > theirs[:position] ||
    #     (ours[:position] == theirs[:position] && !win_tiebreakers )
    #     transformed_op[:position] =
    #       transformed_op[:position] + theirs[:text].length
    #   end

    #   transformed_op
    # end

    # #transfom
    # def call
    #   left = Array(@left)
    #   top = Array(@top)

    #   return [left, top] if left.empty? || top.empty?

    #   if left.length == 1 && top.length == 1
    #     right = transform_operation(left.first, top.first, true)
    #     bottom = transform_operation(top.first, left.first, false)
    #     return [Array(right), Array(bottom)]
    #   end

    #   right = []
    #   bottom = []

    #   left.each do |left_op|
    #     bottom = []

    #     top.each do |top_op|
    #       right_op, bottom_op = call(left_op, top_op)
    #       left_op = right_op
    #       bottom.concat(bottom_op)
    #     end

    #     right.concat(left_op)
    #     top = bottom
    #   end

    #   [right, bottom]
    # end
  end
end
