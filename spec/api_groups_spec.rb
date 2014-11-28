
describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }

  before(:all) {
    @groups = create_list(:group, 4, :with_tariffs)
  }

  it("should raise permission denied on GET groups if not is admin") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups", query: { is_admin: false, token: "12345" }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["error"]).to be_truthy
        expect(response["status"]).to eq(401)
      end
    end
  end

  it("should display group with tariffs in admin session") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups", query: { is_admin: true, token: "12345" }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("groups")
        expect(response["groups"].size).to eq(@groups.size)
        expect(response["groups"][0]["tariffs"].length).to eq @groups.first.tariffs.length
      end
    end
  end

  it("should display group without tariffs in admin session") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups", query: { is_admin: true, token: "12345", with_tariffs: false }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("groups")
        expect(response["groups"].size).to eq(@groups.size)
        expect(response["groups"][0]["tariffs"]).to be nil
      end
    end
  end

  it("updates group tariffs data") do
    @the_group = @groups.first
    @tariff_ids = @the_group.tariffs.map &:id
    @deleted_tariff = @tariff_ids.delete @tariff_ids.first
    @new_tariffs = create_list(:tariff, 3, groups: [@the_group])
    @tariff_ids += @new_tariffs.map &:id
    with_api(Application, api_options) do
      put_request(path: "/api/groups/#{@the_group.id}/tariffs",
                  query: { is_admin: true, token: "12345", tariff_ids: @tariff_ids }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("ok")
        new_tariff_ids = Group.find(@the_group.id).tariffs.map &:id
        expect(new_tariff_ids.length).to eq @tariff_ids.length
        expect(new_tariff_ids).to include @new_tariffs.first.id
        expect(new_tariff_ids).not_to include @deleted_tariff
      end
    end
  end

  it("updates group auth data") do
    @the_group = @groups.first
    with_api(Application, api_options) do
      put_request(path: "/api/groups/#{@the_group.id}",
                  query: { is_admin: true, token: "12345", can_authorize: false }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("ok")
        expect(Group.find(@the_group.id).can_authorize).to eq false
      end
    end
  end

end
