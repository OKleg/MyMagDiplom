module Operations
  class TransformationService < ApplicationService
    def initialize(new_operation, current_version_operations=[])
      @operation = new_operation
      @current_version_operations = current_version_operations
      Rails.logger.info "TransformationService initialize:
      new_operation:#{@operation.inspect}
      current_version_operations:#{current_version_operations}"
    end

    def call #current_version_operations
      # Трансформируем новую операцию относительно всех операций в текущей версии
      @current_version_operations.each do |existing_operation|
        @operation = transform_a(other: existing_operation)
        break if @operation.nil? # Конфликт
      end
      @operation
    end

    # Трансформация текущей операции относительно другой операции
    def transform_a(other:)
      if @operation.input_type == "deleteContentBackward" || @operation.input_type == "deleteContentForward"
        @operation.input_type = "delete"
        @operation.text=""
      end
      Rails.logger.info "transform_a operation: #{@operation.inspect}"

      # insertText deleteContentBackward deleteContentForward
      if @operation.position < other.position ||  @operation.position == other.position && win_operation(@operation, other)
       return @operation
      end
      if other.input_type == "deleteContentBackward" || other.input_type == "deleteContentForward"
        other.input_type = "delete"
      end

      case [@operation.input_type, other.input_type]
      when ['insertText', 'insertText']
        @operation.position =  @operation.position + other.text.length
      when ['insertText', 'delete']
        @operation.position =  @operation.position - 1
      when ['delete', 'insertText']
        @operation.position =  @operation.position + other.text.length
      when ['delete', 'delete']
        if @operation.position > other.position + 1 #other.text.length
          @operation.position =  @operation.position - other.text.length
        else
          nil
        end
      end
      @operation
    end

    private

    def win_operation(our_op,other_op)
      our_op.user_id < other_op.user_id
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
