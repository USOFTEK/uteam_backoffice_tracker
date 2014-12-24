def user_password
  "my_temp_password"
end

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }
  let(:package_params) { { name: Faker::Lorem.words(2).join(" "), source: Faker::Internet.url, desciption: Faker::Lorem.sentence } }
  let(:package_update_params) { { description: Faker::Lorem.sentence, source: Faker::Internet.url } }

  before(:all) {
    @package = create(:tv_package)
    @user = create(:user, password: user_password, network_activities_count: 1)
  }

  it("should respond with TV packages list to admin") do
    with_api(Application, api_options) do
      get_request(path: "/api/tv_packages/#{token}", query: { is_admin: true }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("tv_packages")
        expect(response["tv_packages"]).to be_a_kind_of(Array)
      end
    end
  end

  it("should create TV package if is admin") do
    with_api(Application, api_options) do
      post_request(path: "/api/tv_packages/#{token}", query: { is_admin: true }.merge!(package_params)) do |c|
        expect(c.response_header.status).to eq(201)
      end
    end
  end

  it("should raise permission denied on create TV package if is not admin") do
    with_api(Application, api_options) do
      post_request(path: "/api/tv_packages/#{token}", query: { is_admin: false }.merge!(package_params)) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["error"]).to be_truthy
        expect(response["status"]).to eq(401)
      end
    end
  end
  
  it("should raise permission denied on update package if not is admin") do
    with_api(Application, api_options) do
      put_request(path: "/api/tv_packages/#{@package.id}/#{token}", query: { is_admin: false, name: @package.name }.merge!(package_update_params)) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["error"]).to be_truthy
        expect(response["status"]).to eq(401)
      end
    end
  end

  it("should update package if is admin") do
    with_api(Application, api_options) do
      put_request(path: "/api/tv_packages/#{@package.id}/#{token}", query: { is_admin: true, name: @package.name }.merge!(package_update_params)) do |c|
        expect(c.response_header.status).to eq(200)
      end
    end
  end

  it("should raise permission denied on delete TV package if not is admin") do
    with_api(Application, api_options) do
      delete_request(path: "/api/tv_packages/#{@package.id}/#{token}", query: { is_admin: false } ) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["error"]).to be_truthy
        expect(response["status"]).to eq(401)
      end
    end
  end

  it("should delete TV package if is admin") do
    with_api(Application, api_options) do
      delete_request(path: "/api/tv_packages/#{@package.id}/#{token}", query: { is_admin: true } ) do |c|
        expect(c.response_header.status).to eq(200)
      end
    end
  end

  it("should respond with user tv package and playlist") do
    with_api(Application, api_options) do
      get_request(path: "/api/tv_packages/#{token}", query: { user_id: @user.id } ) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("tv_package")
        expect(response).to have_key("playlist")
      end
    end
  end

end
