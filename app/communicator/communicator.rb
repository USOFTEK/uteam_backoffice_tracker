require "em-synchrony"
require "em-synchrony/em-http"
require "grape"

class Communicator
  attr_reader :is_online

  def initialize main_address, api_class = nil
    addr = main_address
    @address = addr.end_with?("/") ? addr : "#{ addr }/"
    @allowed_methods = %w(get post put patch delete)
    @api_class = api_class
    @is_online = false
    sync_actions
  end

  def sync_actions
    comm = self
    get_json_actions do |resp|
      begin
        res = JSON.parse(resp)
      rescue JSON::ParserError
        next
      end
      if res['actions']
        @is_online = true
        res['actions'].each do |meth, action|
          @api_class.class_eval do
            self.method(meth).call(action) do
              parts = action.split("/").map { |e| e.start_with?(":") ? params.delete(e[1..-1].to_sym) : e }
              parts.delete_if {|e| e.empty? }
              action_name = meth + "_" + parts.join("__")
              comm.send(action_name, params) do |response|
                begin
                  response = JSON.parse(response)
                  if response["error"]
                    response["status"] ||= 400
                    response["message"] ||= "Error"
                    grape_error!(response["message"], response["status"])
                  else
                    response
                  end
                rescue JSON::ParserError
                  response
                end
              end
            end
          end
        end if @api_class
      end
    end
  end

  def method_missing name, params = {}, &meth_blk
    parts = name.to_s.split("_").map{ |e| e.empty? ? '/' : e }
    meth, action = parts.shift, parts.join("_").gsub(/_?\/_?/, "/")
    raise NoMethodError, "No such method: #{name}" unless @allowed_methods.include? meth

    define_singleton_method(name) do |opts={}, &blk|
      link = "#{@address}#{action}"
      request = Proc.new do
        req = EM::HttpRequest.new(link).method(meth).call(body: opts)
        blk.call(link + meth + opts.to_s)
        #blk.call(req.response) if blk
      end
      EM.reactor_running? ? request.call : EM.synchrony { request.call; EM.stop }
    end

    self.send(name, params, &meth_blk)
  end

end