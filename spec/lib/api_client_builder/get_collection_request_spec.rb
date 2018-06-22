require 'spec_helper'
require_relative 'test_client/client'

module APIClientBuilder
  describe GetCollectionRequest do
    describe '#each' do
      context 'request was successful' do
        it 'paginates the collection' do
          client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

          some_objects = client.get_some_objects
          expect(some_objects.count).to eq(9)
        end
      end

      context 'request was unsuccessful' do
        it 'calls the error handlers' do
          client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

          bad_response = APIClientBuilder::Response.new('bad request', 500, [200])
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:get_first_page).and_return(bad_response)
          allow_any_instance_of(TestClient::ResponseHandler).to receive(:retry_request).and_return(bad_response)
          expect { client.get_some_objects.each {} }.to raise_error(
            APIClientBuilder::DefaultPageError, /Error Code: 500/
          )
        end

        context 'request was successful after retryable error' do
          it 'yields the good response' do
            client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

            bad_response = APIClientBuilder::Response.new('bad request', 500, [200])
            good_response = APIClientBuilder::Response.new([1, 2, 3], 200, [200])
            allow_any_instance_of(TestClient::ResponseHandler).to receive(:get_first_page).and_return(bad_response)
            allow_any_instance_of(TestClient::ResponseHandler).to receive(:more_pages?).and_return(false)
            allow_any_instance_of(TestClient::ResponseHandler).to receive(:retry_request).and_return(good_response)

            some_objects = client.get_some_objects
            expect(some_objects.count).to eq(3)
          end
        end

        context 'request was unsuccessful after non-retryable error' do
          it 'calls the error handlers' do
            client = TestClient::Client.new(domain: 'https://www.domain.com/api/endpoints/')

            bad_response = APIClientBuilder::Response.new('bad request', 400, [200])
            good_response = APIClientBuilder::Response.new([1, 2, 3], 200, [200])
            allow_any_instance_of(TestClient::ResponseHandler).to receive(:get_first_page).and_return(bad_response)
            allow_any_instance_of(TestClient::ResponseHandler).to receive(:more_pages?).and_return(false)
            allow_any_instance_of(TestClient::ResponseHandler).to receive(:retry_request).and_return(good_response)
            expect { client.get_some_objects.each {} }.to raise_error(
              APIClientBuilder::DefaultPageError, /Error Code: 400/
            )
          end
        end
      end
    end
  end
end
