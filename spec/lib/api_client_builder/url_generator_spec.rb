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
