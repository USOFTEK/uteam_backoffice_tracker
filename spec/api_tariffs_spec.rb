
describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }
  let(:tv_package) { create(:tv_package) }

  before(:all) {
    @user = create(:user, password: "temp_password")
    @tariffs = create_list(:tariff, 5, groups: [@user.group])
  }

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
    with_api(Application, api_options) do
      get_request(path: "/api/tariffs/#{token}", query: { user_id: @user.id }) do |c|
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

  it("should update tariff TV package") do
    with_api(Application, api_options) do
      tariff = @tariffs.sample
      put_request(path: "/api/tariffs/#{tariff.id}/#{token}", query: { is_admin: true, tv_package_id: tv_package.id }) do |c|
        expect(c.response_header.status).to eq(200)
      end
    end
  end

  it("should delete tariff TV package") do
    with_api(Application, api_options) do
      tariff = @tariffs.sample
      put_request(path: "/api/tariffs/#{tariff.id}/#{token}", query: { is_admin: true, tv_package_id: 0 }) do |c|
        expect(c.response_header.status).to eq(200)
        tariff.reload
        expect(tariff.tv_package).to be_nil
      end
    end
  end

end
