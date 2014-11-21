
def user_password
  "my_user_password"
end

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }
  let(:custom_email) { Faker::Internet.email }
  let(:custom_data) { { chat_notification: false, created_at: Time.now, "mobile_phone_attributes[number]" => FactoryGirl.generate(:build_phone_number) } }

  before(:all) { @user = create(:user, password: user_password, network_activities_count: 100) }

  it("should raise not found if token missed") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/", query: { user_id: @user.id }) do |c|
        expect(c.response_header.status).to eq(404)
      end
    end
  end

  it("should respond with user data") do
    with_api(Application, api_options) do
      post_request(path: "/api/users/check", query: { username: @user.username, password: user_password }) do |c|
        response = JSON.parse(c.response)
        expect(response["id"]).to eq(@user.id)
      end
    end
  end

  it("should raise unauthorized error if user not exists or invalid data") do
    with_api(Application, api_options) do
      post_request(path: "/api/users/check", query: { username: @user.username, password: "" }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(c.response_header.status).to eq(401)
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
        expect(response).to have_key("mobile_phone")
        expect(response["mobile_phone"]["number"]).to eq(@user.mobile_phone.number)
        expect(response).to have_key("primary_phone")
        expect(response["primary_phone"]["number"]).to eq(@user.primary_phone.number)
      end
    end
  end

  it("should raise unauthorized in user profile within token with invalid user id") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/#{token}", query: { user_id: 10 }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(c.response_header.status).to eq(401)
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

  it("should respond with user network statistics in days range") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/networks/#{token}", query: { user_id: @user.id, from: 0 }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("netstats")
        expect(response["netstats"]).not_to be_empty
      end
    end
  end

  it("should respond with user network statistics per month in weeks range") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/networks/#{token}", query: { user_id: @user.id, month: (Time.now - 1.month).month }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("netstats")
        expect(response["netstats"]).to be_an(Array)
        expect(response["netstats"]).not_to be_empty
      end
    end
  end

  it("should respond with user network statistics per year") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/statistics/networks/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("netstats")
        expect(response["netstats"]).to be_an(Array)
        expect(response["netstats"]).not_to be_empty
      end
    end
  end

  it("should update user email") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/email/#{token}", query: { user_id: @user.id, email: custom_email }) do |c|
        expect(c.response_header.status).to eq(200)
      end
    end
  end

  it("should raise invalid user email") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/email/#{token}", query: { user_id: @user.id, email: "test.com" }) do |c|
        expect(c.response_header.status).to eq(400)
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
        expect(@user.chat_notification).to eq(custom_data[:chat_notification])
        expect(Time.at(@user.created_at).to_i).not_to eq(Time.at(custom_data[:created_at]).to_i)
        expect(@user.mobile_phone.number).to eq(custom_data["mobile_phone_attributes[number]"])
      end
    end
  end

  it("should respond with user public fields within user session token") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/fields/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("available")
      end
    end
  end

  it("should respond with user public fields within admin session token") do
    with_api(Application, api_options) do
      get_request(path: "/api/users/profile/fields/#{token}", query: { is_admin: true }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("available")
      end
    end
  end

  it("should raise bad request on update user profile without fields") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/#{token}", query: { user_id: @user.id }) do |c|
        expect(c.response_header.status).to eq(400)
      end
    end
  end

  it("should set sample user public field as disallowed to update") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/fields/#{token}", query: { is_admin: true, fields: { "0" => @user.class.public_fields.sample } }) do |c|
        response = JSON.parse(c.response)
        expect(c.response_header.status).to eq(200)
        expect(response).to have_key("available")
        expect(response["available"].values).to contain_exactly(true, false)
      end
    end
  end

  it("should raise permission denied for user avaliable fields for update") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/fields/#{token}", query: { user_id: @user.id, fields: Hash[@user.class.public_fields.each_with_index.map { |e,i| [i,e.to_s] }] }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["status"]).to eq(401)
      end
    end
  end

  it("should update user avaliable fields as disallowed and return") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/fields/#{token}", query: { is_admin: true, fields: Hash[@user.class.public_fields.each_with_index.map { |e,i| [i,e.to_s] }] }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("available")
        expect(response["available"].values.uniq).to contain_exactly(false)
      end
    end
  end

  it("should allow all user public fields to update") do
    with_api(Application, api_options) do
      put_request(path: "/api/users/profile/fields/#{token}", query: { is_admin: true }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("available")
        expect(response["available"].values.uniq).to contain_exactly(true)
      end
    end
  end

end
