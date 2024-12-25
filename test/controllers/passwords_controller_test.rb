require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:alex)
  end

  test "#edit" do
    get edit_password_path
    assert_response :success
  end
  test "#update with valid params updates the user's password" do
    patch password_path, params: {
      password: {
        password: "newpassword",
        password_confirmation: "newpassword",
        password_challenge: "password"
      }
    }
    assert_redirected_to dashboard_path
    assert users(:alex).reload.authenticate("newpassword")
  end
  test "#update with nil password challenge does not update the user's password" do
    patch password_path, params: {
      password: { password: "newpassword", password_confirmation: "newpassword" }
    }
    assert_response :unprocessable_entity
    assert_not users(:alex).reload.authenticate("newpassword")
  end
end
