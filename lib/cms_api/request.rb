module Request

  TARGET_APP = :webr

# PerceptiveAuth
  unless defined?(self::HTTP_AUTH_CREDENTIALS)
    BASE_HEADERS = {
        :'Accept'                => 'json',
        :'Content-Type'          => 'json',
        :'Perceptive-Company-Id' => 'cms'
    }
    HTTP_AUTH_CREDENTIALS = {
        grant_type:    :client_credentials,
        client_id:     '-dly1d6SYi4m3sBHzWWfnw',
        client_secret: 'A4siILOaLhjGnxALlubRtw'
    }
    HTTP_AUTH_URL = 'https://auth.psft.co/oauth/token'
  end

  def send_request(params)
    return unless params[:method]
    # Prints the URl to be called
    ap "URL: #{params[:method].upcase} #{build_request_url(params)}" if params[:debug]
    begin
      # TODO: insert api request call stats here? (count...)
      response = RestClient::Request.execute(
          {method: params[:method], url: build_request_url(params),
             headers: headers}.merge(timeout_options)
      )
    rescue StandardError => err
      ap "Error: #{err}" if params[:debug]
    end
    if params[:debug]
      ap "Response: "
      ap JSON.parse(response)
    end
    return response
  end

  def build_request_url(params_hsh)
    params = params_hsh.clone
    tenants       = params[:tenants] || app_options[:tenants]

    title         = URI.escape(params[:title]) if params[:title]
    params.delete(:title)

    # using subject instead of resource so that it's consistent with Webr
    subject       = params.delete(:subject) || "content_items"
    content_type  = (subject == "content_items" && params[:content_type].nil? && params[:task].nil?) ? nil : params[:content_type]
    params.delete(:content_type)

    version       = app_options[:version] || "v1"
    guid          = params.delete(:guid) || params.delete(:id)
    task          = params.delete(:task)

    path = "/#{version}/#{subject}"
    path += "/#{guid}" if guid
    path += "/#{task}" if task

    query = "tenants=#{tenants}"
    query += "&title=#{title}" if title
    query += "&content_type=#{content_type}" if content_type

    # now process and add the rest of the params to the query string
    keys_to_remove = %i{subject method tenants}
    params.delete_if{|k,v| keys_to_remove.include? k}
    query += "&" + hash_to_query(params)

    URI::HTTP.build({
      scheme: app_options[:uris][TARGET_APP][:scheme],
      host: app_options[:uris][TARGET_APP][:host],
      port: app_options[:uris][TARGET_APP][:port],
      path: path,
      query: query
    }).to_s
  end

  def hash_to_query(hash)
    URI.encode(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
  end

  private

  def auth_header
    {authorization: "Bearer #{get_access_token_via_http}"}
  end

  def get_access_token_via_http
    ### TODO: Some sort of retry mechanism.
    return @access_token if @access_token
    response_json = RestClient.post(HTTP_AUTH_URL, HTTP_AUTH_CREDENTIALS)
    response_hash = JSON.parse(response_json)
    @access_token = response_hash['access_token']
  end
  # END PerceptiveAuth

  def headers
    BASE_HEADERS.merge(auth_header)
  end

end
