module SessionTestHelper
  def sign_in(user)
    post session_path, params: { session: { email: user.email, password: "password" } }
  end

  def assert_signed_in
    get authenticated_path
    assert_response :success
  end

  def assert_not_signed_in
    get authenticated_path
    assert_redirected_to new_session_path
  end

  def authenticated_path
    dashboard_path
  end

end
