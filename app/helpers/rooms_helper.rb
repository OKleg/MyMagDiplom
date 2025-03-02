module RoomsHelper
  # def transform(left, top)
  #   left = Array(left)
  #   top = Array(top)

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
  #       right_op, bottom_op = transform(left_op, top_op)
  #       left_op = right_op
  #       bottom.concat(bottom_op)
  #     end

  #     right.concat(left_op)
  #     top = bottom
  #   end

  #   [right, bottom]
  # end
end
