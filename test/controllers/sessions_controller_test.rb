require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders login page" do
    get login_path

    assert_response :success
    assert_select "h1", "Вход в систему"
  end

  test "signs in with valid credentials" do
    post login_path, params: { email: users(:engineer).email, password: "password123" }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select ".user-chip__name", users(:engineer).full_name
    assert_select "h1", "Панель управления"
  end

  test "rejects invalid credentials" do
    post login_path, params: { email: users(:engineer).email, password: "wrong-password" }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select ".flash--danger", /Неверный email или пароль/
  end

  test "rejects inactive user" do
    users(:engineer).update!(active: false)

    post login_path, params: { email: users(:engineer).email, password: "password123" }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "logs out" do
    sign_in_as users(:engineer)

    delete logout_path

    assert_redirected_to login_path
    follow_redirect!
    assert_select "h1", "Вход в систему"
  end

  test "redirects authenticated user away from login page" do
    sign_in_as users(:engineer)

    get login_path

    assert_redirected_to root_path
  end
end