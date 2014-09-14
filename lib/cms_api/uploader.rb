require_relative "./base_object"

class Uploader < BaseObject
  class << self

    # TODO: YARD
    # required params: params[:tenant]
    # required params: params[:title]
    # required params: params[:content_type]
    def get_upload_url(params)
      response = send_request({
        method: :get,
        subject: "content_items",
        guid: "111", # FIXME: fix in Webr's route
        task: "request_upload_url"
      }.merge(params))
      parsed_response = Response.parse_response(response)
      return parsed_response[:result] if parsed_response
      nil
    end

    # TODO: YARD
    # required params: params[:tenant]
    # required params: params[:title]
    # required params: params[:content_type]
    def upload_file(params)
      upload_info = get_upload_url(params)
      file_path   = params[:file_path]
      return if !upload_info || !file_path
      res = RestClient.post(
        upload_info[:upload_url],
        {
          file: File.new(file_path)
        }
      )
      res_hsh = Response.parse_response(res) if res
      return res_hsh.merge(upload_info) if res_hsh
      nil
    end

    # TODO: YARD
    # required params: params[:aid]
    def get_download_url(params)
      download_request(params.merge(task: "download_url"))
    end

    def download_file(params)
      download_request(params.merge(task: "file"))
    end

    # TODO: move to spec/support since it is only used for this spec test suite
    def delete_downloaded_file(file_destination)
      File.delete(file_destination) if File.exist?(file_destination)
      puts 'Deleted downloaded file'
    end

    private

    def download_request(params)
      return if !params[:aid] || !params[:task]
      response = send_request({
        method: :get,
        subject: "content_assets",
        guid: params[:aid],
        task: params[:task]
      }.merge(params))
      if response
        if params[:task] == "file"
          return unless params[:file_destination]
          File.open(params[:file_destination], "w") do |f|
            f.write(response)
          end
        elsif params[:task] == "download_url"
          parsed_response = Response.parse_response(response)
          return parsed_response[:result] if parsed_response
        end
      end
      nil
    end

  end # self
end