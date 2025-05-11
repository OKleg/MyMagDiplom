require "rails_helper"

RSpec.describe OperationsChannel, type: :channel do
  fixtures :users
# User.create!(email:"alex@doe.com", password_digest: BCrypt::Password.create("password"))
  let(:room) { Room.create!(name: "Test Room") }
  let(:user) { User.create!(email: 'test@example.com', password: 'password')  }

  # User.create(email: "test@doe.com", password: BCrypt::Password.create("password"))
  before do
    ActiveJob::Base.queue_adapter = :test
    # initialize connection with identifiers
    stub_connection( room_id: room.id, user_id: user.id)
  end

  describe "#subscribed" do
    it "successfully subscribes to a room stream" do
      subscribe(room_id: room.id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("operation_channel_#{room.id}")
    end
  end

  describe "#receive" do
    before { subscribe(room_id: room.id) }

    context "when receiving update_text data" do
      let(:data) { { "status" => "update_text", "type" => "insertText", "text" => "a","position" => 0, "version" => 0, "action"=>"receive" } }

      it "enqueues a TransformationJob" do
        expect {
          perform :receive, data
        }.to have_enqueued_job(TransformationJob).with(data: data)
      end
      # it "broadcast " do
      #   expect {
      #     perform :receive, data
      #   }.to have_broadcasted_to("operation_channel_#{room.id}").with(
      #     status: "update_text",
      #     operation: hash_including(text: "a")
      #   )
      # end
    end

    context "when receiving connect_user data" do
      let(:data) { { "status" => "connect_user" } }

      it "calls connect_user method" do
        expect_any_instance_of(OperationsChannel).to receive(:connect_user)
        perform :receive, data
      end
    end
  end

  describe "#connect_user" do
    # before { subscribe(room_id: room.id) }

    # it "broadcasts user connection data" do
    #   puts User.first.inspect
    #   expect {
    #     perform :receive, { "status" => "connect_user" }
    #   }.to have_broadcasted_to("operation_channel_#{room.id}").with(
    #     status: "connect_user",
    #     content: room.content,
    #     user: { id: user.id, email: user.email },
    #     version: room.version
    #   )
    # end
  end

end
