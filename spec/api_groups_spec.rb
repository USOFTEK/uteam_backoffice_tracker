
describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }

  before(:all) {
    @groups = create_list(:group, 4)
  }

  it("should raise permission denied on GET groups if not is admin") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups/#{token}", query: { is_admin: false }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["error"]).to be_truthy
        expect(response["status"]).to eq(401)
      end
    end
  end

  it("should display group within admin session") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups/#{token}", query: { is_admin: true }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("groups")
        expect(response["groups"].size).to eq(@groups.size)
      end
    end
  end

end
