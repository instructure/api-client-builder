require 'spec_helper'

module APIClientBuilder
  describe Response do
    describe '#success?' do
      it 'returns true when the given code is included in the given range' do
        page = Response.new([], 200, [200])

        expect(page.success?).to eq(true)
      end

      it 'returns false when the given code is included in the given range' do
        page = Response.new([], 400, [200])

        expect(page.success?).to eq(false)
      end

      it 'returns false when the response is otherwise marked as failed' do
        page = Response.new([], 200, [200])
        page.mark_failed 'Something happened'

        expect(page.success?).to eq(false)
      end
    end
  end
end
