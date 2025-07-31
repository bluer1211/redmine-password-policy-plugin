require File.expand_path('../../../test_helper', __FILE__)

class PasswordPolicyPluginTest < ActionController::TestCase
  fixtures :users, :settings

  def setup
    @controller = PasswordPoliciesController.new
    @request = ActionController::TestRequest.create(@controller.class)
    @response = ActionController::TestResponse.new
    @user = User.find(1) # admin user
    User.current = @user
  end
end 