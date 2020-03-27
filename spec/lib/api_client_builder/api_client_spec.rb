require 'spec_helper'
require_relative 'test_client/client'

module APIClientBuilder
  describe APIClient do
    let(:domain) { 'https://www.domain.com/api/endpoints/' }
    let(:client) { TestClient::Client.new(domain: domain) }

    describe '.get' do
      context 'plurality is :collection' do
        it 'defines a get method that returns a GetCollectionRequest' do
          expect(client).to respond_to(:get_some_objects)
          expect(client.get_some_objects).to be_a(APIClientBuilder::GetCollectionRequest)
        end
      end

      context 'plurality is :singular' do
        it 'defines a get method that returns a GetItemRequest' do
          expect(client).to respond_to(:get_some_object)
          expect(client.get_some_object(some_id: '123')).to be_a(APIClientBuilder::GetItemRequest)
        end
      end
    end

    describe '.post' do
      it 'defines a post method on the client' do
        expect(client).to respond_to(:post_some_object)
      end

      it 'returns a PostRequest object' do
        expect(client.post_some_object({})).to be_a(APIClientBuilder::PostRequest)
      end
    end

    describe '.put' do
      it 'defines a put method on the client' do
        expect(client).to respond_to(:put_some_object)
      end

      it 'returns a PutRequest object' do
        expect(client.put_some_object({})).to be_a(APIClientBuilder::PutRequest)
      end
    end

    describe '.delete' do
      it 'defines a delete method on the client' do
        expect(client).to respond_to(:delete_some_object)
      end

      it 'returns a DeleteRequest object' do
        expect(client.delete_some_object({})).to be_a(APIClientBuilder::DeleteRequest)
      end
    end
  end
end
