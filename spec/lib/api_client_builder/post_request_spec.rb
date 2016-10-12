require 'spec_helper'
require 'api_client_builder/post_request'
require 'lib/api_client_builder/test_client/client'

module APIClientBuilder
  describe PostRequest do
    describe '#response' do
      context 'request was successful' do
        it 'returns a response object' do
          client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

          some_object = client.post_some_object({}).response
          expect(some_object.body).to eq('good request')
        end
      end

      context 'request was unsuccessful' do
        it 'calls the error handlers' do
          client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

          bad_response = APIClientBuilder::Response.new('bad request', 400, [200])
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:post_request).and_return(bad_response)
          expect{ client.post_some_object({}).response }.to raise_error(
            APIClientBuilder::DefaultPageError,
            "Default error for bad response. If you want to handle this error use #on_error on the response in your api consumer. Error Code: 400"
          )
        end
      end
    end
  end
end
