require_relative "spec_helper"

def user_password
  "my_user_password"
end

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }
  let(:custom_email) { Faker::Internet.email }
  let(:custom_data) { { initials: Faker::Name.name, created_at: Time.now } }

  before(:all) { @user = create(:user, password: user_password) }

  it("should respond with user data") do
    with_api(Application, api_options) do
      post_request(path: "/api/users/check", query: { username: @user.username, password: user_password }) do |c|
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
      get_request(path: "/api/users/billing/payments/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("payments")
        expect(response["payments"].count).to eq(@user.payments.count)
      end
    end
  end
  it("should respond with user fees") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/billing/fees/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("fees")
        expect(response["fees"].count).to eq(@user.fees.count)
      end
    end
  end
  it("should respond with user network statistics") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/networks/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("netstats")
        expect(response["netstats"].count).to eq(@user.network_activities.count)
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
  it("should unset user password") do
    with_api(Application, api_options) do
      delete_request(path: "/api/users/profile/password/#{token}", query: { user_id: @user.id }) do |c|
        @user.reload
        expect(c.response_header.status).to eq(200)
        expect(@user.password).to eq("")
      end
    end
  end
  it("should update user_profile with custom data by public fields") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/#{token}", query: { user_id: @user.id }.merge!(custom_data)) do |c|
        @user.reload
        expect(@user.initials).to eq(custom_data[:initials])
        expect(Time.at(@user.created_at).to_i).not_to eq(Time.at(custom_data[:created_at]).to_i)
      end
    end
  end
  it("should respond with empty disallowed fields") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/fields/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("disallowed_fields")
        expect(response["disallowed_fields"].empty?).to eq(true)
      end
    end
  end
  it("should set and display a disallowed fields for user") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/update/fields/#{token}", query: { is_admin: true, fields: @user.class.public_fields }) do |c|
        expect(c.response_header.status).to eq(200)
      end
    end
  end
  it("should respond with disallowed fields for user") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/fields/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("disallowed_fields")
        expect(response["disallowed_fields"].size).to eq(@user.class.public_fields.count)
      end
    end
  end

end
