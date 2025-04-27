require 'rails_helper'

describe User, type: :model do
  fixtures :users

  context 'validations' do

    it "is valid with a valid email and password" do
      valid_password = "password"
      user = User.new email: "alex@newuser.com", password: valid_password
      expect(user).to  be_valid
      # assert_includes user.errors.full_messages, "Password is too short (minimum is 4 characters)"
    end

    it "is invalid because the password must be at least #{User::MINIMUM_PASSWORD_LENGTH} characters" do
      invalid_password = "a" * (User::MINIMUM_PASSWORD_LENGTH - 1)
      user = User.new email: "alex@newuser.com", password: invalid_password
      expect(user).to_not  be_valid
      # assert_includes user.errors.full_messages, "Password is too short (minimum is 4 characters)"
    end

    it "is invalid because  password must be present" do
      user = User.new email: "alex@doe.com", password: ""

      expect(user).to_not  be_valid #, "Password can't be blank"
    end

    it "is invalid because email must be uniqueness" do
      user = users(:alex).dup
      user.email = "   #{user.email.upcase}   "
      user.password = "password"

      expect(user).to_not  be_valid
      # assert_equal ["has already been taken"], user.errors[:email]
    end

    # it "should get show" do
    #   # sign_in users(:alex)
    #   # get dashboard_path
    #   # expect(response).to be_success
    # end

  end
end
