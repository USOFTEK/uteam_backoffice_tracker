
describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }
  let(:user) { create(:user, password: "temp_password") }

  it("should respond with tariffs list to admin") do
    with_api(Application, api_options) do
      get_request(path: "/api/tariffs/#{token}", query: { is_admin: true }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("tariffs")
        expect(response["tariffs"].count).to eq(Tariff.count)
      end
    end
  end

  it("should respond with tariffs list to user") do
    @tariffs = create_list(:tariff, 5, groups: [user.group])
    with_api(Application, api_options) do
      get_request(path: "/api/tariffs/#{token}", query: { user_id: user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("tariffs")
        expect(response["tariffs"].count).to eq(@tariffs.count)
      end
    end
  end

  it("should raise unauthorized if user not found") do
    with_api(Application, api_options) do
      get_request(path: "/api/tariffs/#{token}", query: { user_id: nil }) do |c|
        expect(c.response_header.status).to eq(401)
      end
    end
  end

end
