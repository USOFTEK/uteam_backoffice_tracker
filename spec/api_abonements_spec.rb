
def user_password
  "my_user_password"
end

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }

  before(:all) {
    @user = create(:user, password: user_password, network_activities_count: 1)
    @abonements = create_list(:abonement, 4)
  }

  it("shoud display all abonements within session") do
    with_api(Application, api_options) do
      get_request(path: "/api/abonements/#{token}", query: { user_id: @user.id }) do |c|
        response = JSON.parse(c.response)
        expect(response).not_to have_key("error")
        expect(response).to have_key("abonements")
        expect(response["abonements"].size).to eq(@abonements.size)
      end
    end
  end

end
