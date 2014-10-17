require_relative "spec_helper"

def user_password
  "my_user_password"
end

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }
  let(:custom_email) { Faker::Internet.email }

  before(:all) { @user = create(:user, password: user_password) }

  it("should respond with user data") do
    with_api(Application, api_options) do
      post_request(path: "/api/users/check/#{@user.username}/#{user_password}") do |c|
        response = JSON.parse(c.response)
        expect(response["id"]).to eq(@user.id)
      end
    end
  end
  it("should respond with user profile within token") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response["id"]).to eq(@user.id)
        expect(response).to have_key("tariff")
        expect(response).to have_key("billing")
        expect(response).to have_key("phones")
      end
    end
  end
  it("should respond with user payments") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/payments/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response.count).to eq(@user.payments.count)
      end
    end
  end
  it("should respond with user fees") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/fees/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response.count).to eq(@user.fees.count)
      end
    end
  end
  it("should respond with user network statistics") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/networks/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response.count).to eq(@user.network_activities.count)
      end
    end
  end
  it("should update user email") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/update/email/#{token}", query: { user_id: @user.id, email: custom_email }) do |c|
        expect(c.response_header.status).to eq(200)
      end
    end
  end

end