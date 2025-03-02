class OperationTransformationService < ApplicationService
  def initialize(others:, ours: )
    @left = others
    @top = ours
  end

  def transform_operation(ours, theirs, win_tiebreakers)
    # TODO: handle other kinds of operations

    transformed_op = ours.dup

    if ours[:position] > theirs[:position] ||
      (ours[:position] == theirs[:position] && !win_tiebreakers )
      transformed_op[:position] =
        transformed_op[:position] + theirs[:text].length
    end

    transformed_op
  end

  #transfom
  def call
    left = Array(@left)
    top = Array(@top)

    return [left, top] if left.empty? || top.empty?

    if left.length == 1 && top.length == 1
      right = transform_operation(left.first, top.first, true)
      bottom = transform_operation(top.first, left.first, false)
      return [Array(right), Array(bottom)]
    end

    right = []
    bottom = []

    left.each do |left_op|
      bottom = []

      top.each do |top_op|
        right_op, bottom_op = call(left_op, top_op)
        left_op = right_op
        bottom.concat(bottom_op)
      end

      right.concat(left_op)
      top = bottom
    end

    [right, bottom]
  end
end
