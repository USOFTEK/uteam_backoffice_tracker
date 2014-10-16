require_relative "spec_helper"

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }
  let(:token) { Faker::Internet.ip_v6_address.tr(":", "") }

  before(:all) { @tariffs = create_list(:tariff, 3) }
  
  it("should respond with tariffs list") do
    with_api(Application, api_options) do
      get_request(path: "/api/tariffs/#{token}") do |c|
        response = JSON.parse(c.response)
        expect(response.count).to eq(@tariffs.count)
      end
    end
  end

end
