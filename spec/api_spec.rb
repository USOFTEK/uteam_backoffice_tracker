require_relative "spec_helper"

describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }

  it("should respond with tariffs list") do
    with_api(Application, api_options) do
      get_request(path: "/api/json_actions") do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("actions")
      end
    end
  end

end
