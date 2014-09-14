require_relative "./setup"
require_relative "./response"
require_relative "./request"

class BaseObject
  extend Request

  class << self

    def create(params)
      send_request_and_parse_response(params.merge(method: :post))
    end

    def find(opts = {})
      result = send_request_and_parse_response(opts.merge(method: :get, use_result_key: true))
      result ? result : []
    end

    def all; find; end

    def delete(params)
      params_clone = params.clone
      guid = params_clone.delete(:guid)
      return {error: 'no GUID provided'} unless guid
      send_request({method: :delete, subject: subject, guid: guid}.merge(params_clone))
    end

    def update(params)
      return unless params[:guid]
      send_request_and_parse_response(params.merge(method: :put))
    end

    # TODO: move to request.rb
    def send_request_and_parse_response(params)
      response = send_request({
        subject: subject
      }.merge(params))
      if response
        result = Response.parse_response(response)
        return !!params[:use_result_key] ? result[:result] : result
      end
      nil
    end

    def subject; self.name.underscore.pluralize; end

    def delete_many(guids)
      guids.each { |guid| delete(guid) }
    end

    def exists?(guid)
      !find(guid: guid).empty?
    end


  end # self
end
