require 'spec_helper'
require 'lib/api_client_builder/test_client/client'
require 'api_client_builder/request'

module APIClientBuilder
  describe Request do
    describe '#error_handlers' do
      context 'no error handlers' do
        it 'returns the default error handler' do
          client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

          bad_response = APIClientBuilder::Response.new('bad request', 400, [200])
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:get_first_page).and_return(bad_response)
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:retry_request).and_return(bad_response)
          expect{ client.get_some_object(some_id: '123').response }.to raise_error(
            APIClientBuilder::DefaultPageError,
            "Default error for bad response. If you want to handle this error use #on_error on the response in your api consumer. Error Code: 400"
          )
        end
      end

      context 'defined error handler' do
        it 'returns the custom handler' do
          client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

          bad_response = APIClientBuilder::Response.new('bad request', 400, [200])
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:get_first_page).and_return(bad_response)
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:retry_request).and_return(bad_response)
          object_response = client.get_some_object(some_id: '123')

          object_response.on_error do |page, response|
            raise StandardError, "Something Bad Happened"
          end

          expect{object_response.response}.to raise_error(
            StandardError,
            "Something Bad Happened"
          )
        end
      end
    end
  end
end
