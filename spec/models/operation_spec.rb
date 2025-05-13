require 'rails_helper'

describe Operation, type: :model do
  fixtures :users

  context 'operation_transformation' do

    describe "#transform" do
    let(:room) { Room.create!(name: "Test Room", content: "cat", version: 2) }
    before do
      room.operations.create!(user: users(:alex),input_type: "insertText", position: 0, text: "a", version: 1)
      room.operations.create!(user: users(:joe),input_type: "insertText", position: 1, text: "t", version: 2)
      room.operations.create!(user: users(:jeanne),input_type: "insertText", text: "c", position: 0, version: 3)
    end

      it "calls TransformationService with current insert operation" do
        new_operation = Operation.new(room: room, user: users(:alex), input_type: "insertText",
          text: "r", position: 1, version: 2,)
        current_version_operations = new_operation.operations_to_current_version
        transformed_operation = Operations::TransformationService.call(new_operation,current_version_operations)
        expect(transformed_operation.position).to  eq(2)
      end

      it "calls TransformationService with delete operation" do
        new_operation = Operation.new(room: room, user: users(:joe), input_type: "delete",
          text: "", position: 1, version: 2,)
        current_version_operations = new_operation.operations_to_current_version
        transformed_operation = Operations::TransformationService.call(new_operation,current_version_operations)
        expect(transformed_operation.position).to  eq(2)
      end

      it "calls transform in insert operation" do
        new_operation = described_class.new(
          room: room,
          user: users(:alex),
          input_type: "insertText",
          text: "r",
          position: 1,
          version: 2,
        )
        is_transformed = new_operation.transform
        expect(is_transformed).to be true
        expect(new_operation.position).to eq(2)
        expect(room.content).to eq("cart")
      end

      it "calls transform in insert operation after end pos" do
        new_operation = described_class.new(
          room: room,
          user: users(:alex),
          input_type: "insertText",
          text: "e",
          position: 4,
          version: 2,
        )
        is_transformed = new_operation.transform
        expect(is_transformed).to be true
        expect(new_operation.position).to eq(5)
        # expect(Operation.find_by(new_operation.id).position).to eq(3)
        # expect(room.content).to eq("cate")
      end

      it "calls transform in delete operation after delete in equal position" do

        previos_operation = described_class.new(
          room: room,
          user: users(:joe),
          input_type: "deleteContentBackward",
          text: "",
          position: 1,
          version: 2,
        )
        previos_op_transformed = previos_operation.transform
        new_operation = described_class.new(
          room: room,
          user: users(:alex),
          input_type: "deleteContentBackward",
          text: "",
          position: 1,
          version: 2,
        )
        new_op_transformed = new_operation.transform
        expect(previos_operation.position).to eq(2)
        expect(previos_op_transformed).to be true
        expect(new_op_transformed).to be false

        expect(room.content).to eq("ca")
      end

    end



  end
end
