require 'spec_helper'

module APIClientBuilder
  describe URLGenerator do
    describe '#build_route' do
      context 'route with colon params and matching keys' do
        it 'replaces to route keys with their respective values' do
          url_generator = URLGenerator.new('https://www.domain.com/api/endpoints/')

          route = url_generator.build_route(
            'object_one/:object_one_id/:object_one_id/route_to_object/:other_object_id/object',
            object_one_id: '4',
            other_object_id: '10'
          )

          expect(route).to eq(URI.parse('https://www.domain.com/api/endpoints/object_one/4/4/route_to_object/10/object'))
        end

        it 'replaces to route keys with their respective values in embedded params' do
          url_generator = URLGenerator.new('https://www.domain.com/api/endpoints/')

          route = url_generator.build_route(
            'object_one/:object_one_id/:object_one_id/object&as_user_id=:user_object_id',
            object_one_id: '4',
            user_object_id: '1'
          )
          expect(route).to eq(URI.parse('https://www.domain.com/api/endpoints/object_one/4/4/object&as_user_id=1'))
        end

        it 'encodes the URI correctly' do
          url_generator = URLGenerator.new('https://www.domain.com/api/endpoints/')

          route = url_generator.build_route(
            'route_to_object/:object_id/object/:query_string',
            object_id: "\u1F4a9",
            query_string: "?sample[]=\u1F648\u1F649\u1F64A&success=party\u1F64C"
          )
          expect(route).to eq(URI.parse('https://www.domain.com/api/endpoints/route_to_object/%E1%BD%8A9/object/' \
                                        '?sample[]=%E1%BD%A48%E1%BD%A49%E1%BD%A4A&success=party%E1%BD%A4C'))
        end

        context "and the route has multiple colon params in they query string" do
          let(:url) { 'object_one/:object_one_id/:object_one_id/object&as_user_id=:user_object_id&param_2=:param_2&per_page=100' }
          let(:url_generator) { URLGenerator.new('https://www.domain.com/api/endpoints/') }

          subject do
            route = url_generator.build_route(
              url,
              object_one_id: '4',
              user_object_id: '1',
              param_2: 'anotherqueryparam'
            )
          end

          it do
            is_expected.to eq URI.parse(
              'https://www.domain.com/api/endpoints/object_one/4/4/object&as_user_id=1&param_2=anotherqueryparam&per_page=100'
            )
          end
        end

        context "the route has URL param just after a colon params path" do
          let(:url) { 'objects/:object_id?foo=bar' }
          let(:url_generator) { URLGenerator.new('https://www.domain.com/api/endpoints/') }

          subject do
            route = url_generator.build_route(url, object_id: 1)
          end

          it do
            is_expected.to eq URI.parse('https://www.domain.com/api/endpoints/objects/1?foo=bar')
          end
        end

      end

      context 'route with colon params and non matching keys' do
        it 'raises an argument error' do
          url_generator = URLGenerator.new('https://www.domain.com/api/endpoints/')

          expect do
            url_generator.build_route(
              'object_one/:object_one_id/:object_one_id/route_to_object/:other_object_id/object',
              other_object_id: '10'
            )
          end.to raise_error(ArgumentError, 'Param :object_one_id is required')
        end
      end
    end
  end
end
