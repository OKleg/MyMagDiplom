class TransformationJob < ApplicationJob
  queue_as :default

  def perform(data:)
    operations = data["operations"]
    operation = operations[0] #TODO: fix for any operations
    room = Room.find(data["room_id"])
    user = User.find(data["user_id"])
    new_operation = Operation.new(
      room: room,
      user: user,
      input_type: operation["type"],
      text: operation["text"],
      position: operation["position"],
      version: operation["version"],
    )
    new_operation.transform

    # Do something later
  end
end
