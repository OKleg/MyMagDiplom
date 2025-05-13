require 'rails_helper'

RSpec.describe 'Operation Channel', type: :system, js: true  do
  let(:room) { Room.create!(name: "Test Room") }
  let(:user) { User.create!(email: 'test@example.com', password: 'password')  }
  let(:second_user) { User.create!(email: 'second_user@example.com', password: 'password')  }

  before do
    driven_by(:cuprite)
    sign_up_test_user user
    # visit "/rooms/#{room.id}"
  end

  it "sign in " do
    # expect(Current.user).to eq(user)
  end

  it 'broadcasts updates to all subscribers' do
    # fill_in_editor('T')

    # using_session(:second_user) do
    #   sign_in second_user
    #   visit room_path(room)
    #   expect(page).to have_content('T')
    # end
  end

  def fill_in_editor(text)
    find('trix-editor-1').click.set(text)
  end
end
