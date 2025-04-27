require 'rails_helper'

describe Operation, type: :model do
  fixtures :users

  context 'transformation' do

    describe "#transform" do
    let(:room) { Room.create!(name: "Test Room", content: "cat", version: 2) }
    before do
      room.operations.create!(user: users(:alex),input_type: "insertText", position: 1, text: "a", version: 1)
      room.operations.create!(user: users(:alex),input_type: "insertText", position: 2, text: "t", version: 2)
      room.operations.create!(user: users(:alex),input_type: "insertText", text: "c", position: 1, version: 3)
    end

      it "calls TransformationService with current insert operation" do
        new_operation = Operation.new(room: room, user: users(:alex), input_type: "insertText",
          text: "r", position: 2, version: 2,)
        current_version_operations = new_operation.operations_to_current_version
        transformed_operation = Operations::TransformationService.call(new_operation,current_version_operations)
        expect(transformed_operation.position).to  eq(3)
      end

      it "calls TransformationService with current delete operation" do
        new_operation = Operation.new(room: room, user: users(:alex), input_type: "delete",
          text: "", position: 2, version: 2,)
        current_version_operations = new_operation.operations_to_current_version
        transformed_operation = Operations::TransformationService.call(new_operation,current_version_operations)
        expect(transformed_operation.position).to  eq(3)
      end

      # it "calls transform in insert operation" do
      #   described_class.new(room: room, user: users(:alex), input_type: "insertText",
      #   text: "r", position: 2, version: 2,).transform
      # end


    end



  end
end
