module Response
  class << self
    def error?(response)
      hsh = parse_response(response)
      return false unless hsh
      !hsh[:error].nil?
    end

    def parse_response(response)
      return JSON.parse(response).deep_symbolize_keys if response
      nil
    end

    def parse_id(response)
      hsh = parse_response(response)
      return hsh[:guid] if hsh
      nil
    end
  end
end