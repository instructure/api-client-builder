require 'api_client_builder/response'

module TestClient
  class ResponseHandler
    SUCCESS_STATUS = 200
    SUCCESS_RANGE = [200]
    MAX_RETRIES = 4

    def initialize(client, start_url, type, **opts)
      @retries = 0
    end

    def get_first_page
      @current_page = 0
      APIClientBuilder::Response.new([1,2,3], SUCCESS_STATUS, SUCCESS_RANGE)
    end

    def get_next_page
      @current_page += 1
      APIClientBuilder::Response.new([4,5,6], SUCCESS_STATUS, SUCCESS_RANGE)
    end

    def put_request(body)
      APIClientBuilder::Response.new('good request', SUCCESS_STATUS, SUCCESS_RANGE)
    end

    def post_request(body)
      APIClientBuilder::Response.new('good request', SUCCESS_STATUS, SUCCESS_RANGE)
    end

    def more_pages?
      return false if @current_page >= 2
      return true
    end

    def retryable?(status_code)
      @retries += 1
      status_code != 400 && @retries < MAX_RETRIES
    end

    def retry_request
    end

    def reset_retries
    end
  end
end
