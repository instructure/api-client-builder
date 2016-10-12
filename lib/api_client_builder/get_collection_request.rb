require 'api_client_builder/request'

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
    def each
      if block_given?
        each_page do |page|
          if page.success?
            page.body.each do |item|
              yield(item)
            end
          elsif response_handler.respond_to?(:retryable?) && response_handler.retryable?(page.status_code)
            retried_page = attempt_retry

            retried_page.body.each do |item|
              yield(item)
            end
          else
            notify_error_handlers(page)
          end
        end
      else
        Enumerator.new(self, :each)
      end
    end

    private

    def each_page
      yield(response_handler.get_first_page)
      yield(response_handler.get_next_page) while response_handler.more_pages?
    end
  end
end
