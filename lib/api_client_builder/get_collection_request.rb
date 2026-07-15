# frozen_string_literal: true

module APIClientBuilder
  # The multi item response object to be used as the container for
  # collection responses from the defined API
  class GetCollectionRequest < Request
    include Enumerable

    # Iterates over the pages and yields their items if they're successful
    # responses. Else handles the error. Will retry the response if a retry
    # strategy is defined concretely on the response handler.
    #
    # @return [JSON] the http response body
    def each(&block)
      return Enumerator.new(self, :each) unless block_given?

      each_page do |page|
        if page.success?
          page.body.each(&block)
        elsif response_handler.respond_to?(:retryable?) && response_handler.retryable?(page.status_code)
          retried_page = attempt_retry

          retried_page.body.each(&block)
        else
          notify_error_handlers(page)
        end
      end
    end

    private

    def each_page
      yield(response_handler.get_first_page)
      yield(response_handler.get_next_page) while response_handler.more_pages?
    end
  end
end
