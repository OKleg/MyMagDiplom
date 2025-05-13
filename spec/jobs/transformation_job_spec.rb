describe TransformationJob, type: :job do
  fixtures :users

  context 'transformation_job' do

    describe "#perform" do
      let(:room) { Room.create!(name: "Test Room", content: "cat", version: 2) }
      it "called with perform" do
        # operation = {input_type: "insertText", text: "a", position: 0, version: 0}
        # data = {status: "update_text",
        #   operations: [operation],
        #   room_id: room.id,
        #   user_id: users(:alex).id}
          # TransformationJob.perform.perform_later(data: data);
      end
    end
  end
end
