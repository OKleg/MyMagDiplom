require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "#new is successful when not signed in" do
    get new_session_path
    assert_response :success
  end

  test "#new redirects when signed in" do
    sign_in users(:alex)
    get new_session_path
    assert_redirected_to root_path
  end
  test "#create signs in the user when not signed in" do
    assert_not_signed_in
    sign_in users(:alex)
    assert_redirected_to dashboard_path
    assert_signed_in
  end

  test "#create redirects when already signed in" do
    2.times { sign_in users(:alex) }
    assert_redirected_to root_path
  end

   test "#destroy signs out the user" do
    sign_in users(:alex)
    assert_signed_in
    assert_difference("Session.count", -1) { delete session_path }
    assert_redirected_to root_path
    assert_not_signed_in
  end

  test "#destroy redirects when not signed in" do
    delete session_path
    assert_redirected_to new_session_path
  end


end
