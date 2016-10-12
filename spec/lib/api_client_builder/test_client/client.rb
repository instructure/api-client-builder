require 'api_client_builder/api_client'
require 'lib/api_client_builder/test_client/response_handler'
require 'lib/api_client_builder/test_client/http_client_handler'

module TestClient
  class Client < APIClientBuilder::APIClient
    def initialize(**opts)
      super(domain: opts[:domain],
            response_handler: TestClient::ResponseHandler,
            http_client: TestClient::HTTPClientHandler)
    end

    def response_handler_build(http_client, start_url, type)
      ResponseHandler.new(http_client, start_url, type, exponential_backoff: @exponential_backoff)
    end

    get :some_objects, :collection, 'some/url'
    get :some_object, :singular, 'some/url/:some_id'

    post :some_object, 'some/post/url'
    put :some_object, 'som/put/url'
  end
end
