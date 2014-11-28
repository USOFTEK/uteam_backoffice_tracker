
describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }

  before(:all) {
    @groups = create_list(:group, 4, :with_tariffs)
  }

  it("should raise permission denied on GET groups if not is admin") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups", query: { is_admin: false, token: token }) do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("error")
        expect(response["error"]).to be_truthy
        expect(response["status"]).to eq(401)
      end
    end
  end

  it("should display groups with tariffs in admin session") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups", query: { is_admin: true, token: token }) do |c|
        response = JSON.parse(c.response)
        puts "\n#{response}\n"
        expect(response).not_to have_key("error")
        expect(response).to have_key("groups")
        expect(response["groups"]).to be_kind_of(Array)
      end
    end
  end

  it("should display groups without tariffs in admin session") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups", query: { is_admin: true, token: token, with_tariffs: false }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("groups")
        expect(response["groups"]).to be_kind_of(Array)
      end
    end
  end

  it("displays certain group with tariffs in admin session") do
    with_api(Application, api_options) do
      get_request(path: "/api/groups/#{@groups.last.id}", query: { is_admin: true, token: token }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("groups")
        expect(response["groups"]).to be_kind_of(Hash)
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
      put_request(path: "/api/groups/#{@the_group.id}",
                  query: { is_admin: true, token: token, tariffs: @tariff_ids.to_json }) do |c|
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

  it("empties group tariffs") do
    @the_group = @groups.first
    with_api(Application, api_options) do
      put_request(path: "/api/groups/#{@the_group.id}",
                  query: { is_admin: true, token: token, has_no_tariffs: true }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("ok")
        expect(Group.find(@the_group.id).tariffs.size).to eq 0
      end
    end
  end

  it("updates group auth data") do
    @the_group = @groups.first
    with_api(Application, api_options) do
      put_request(path: "/api/groups/#{@the_group.id}",
                  query: { is_admin: true, token: token, can_authorize: false }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("ok")
        expect(Group.find(@the_group.id).can_authorize).to eq false
      end
    end
  end

end
