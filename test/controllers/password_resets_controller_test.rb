require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "#new" do
    get new_password_reset_path
    assert_response :success
  end

  test "#create" do
    # assert_emails 1 do
    #   post password_reset_path, params: { email: users(:alex).email }
    # end

    # assert_redirected_to root_path
  end

  test "#edit" do
    get edit_password_reset_path
    assert_response :success
  end

  test "#update resets the password with a valid token and valid params" do
    user = users(:alex)
    token = user.generate_token_for(:password_reset)

    patch password_reset_path, params: {
      password_reset_token: token,
      password_reset: { password: "newpassword", password_confirmation: "newpassword" }
    }
    assert_redirected_to dashboard_path
    assert_signed_in
    assert user.reload.authenticate("newpassword")
  end

  test "#update fails without a valid token" do
  patch password_reset_path, params: {
    password_reset_token: "invalid",
    password_reset: { password: "newpassword", password_confirmation: "newpassword" }
  }
  assert_redirected_to new_password_reset_path
  follow_redirect!
  assert_select "main", /Invalid token/
end

test "#update fails if password and password confirmation don't match" do
    user = users(:alex)
    token = user.generate_token_for(:password_reset)

    patch password_reset_path, params: {
      password_reset_token: token,
      password_reset: { password: "newpassword", password_confirmation: "notmatching" }
    }
    assert_response :unprocessable_entity
    assert_select "main", /Password confirmation doesn't match Password/
  end
end
