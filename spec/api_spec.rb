
describe(Application) do

  let(:api_options) { { :config => File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "application.rb")) } }

  it("should respond with json actions list") do
    with_api(Application, api_options) do
      get_request(path: "/api/json_actions") do |c|
        response = JSON.parse(c.response)
        expect(response).to have_key("actions")
      end
    end
  end
  
  it("should respond with swagger doc") do
  	with_api(Application, api_options) do
      get_request(path: "/docs") do |c|
        response = JSON.parse(c.response)
        expect(c.response_header.status).to eq(200)
        expect(response.count).not_to eq(0)
      end
    end
  end

end
