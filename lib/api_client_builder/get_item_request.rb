module APIClientBuilder
  # The single item response object to be used as the container for
  # singular responses from the defined API
  class GetItemRequest < Request
    # Reads the first page from the pagination solution and yields the
    # items if the response was successful. Else handles the error. Will
    # retry the response if a retry strategy is defined concretely on the
    # response handler.
    #
    # @return [JSON] the http response body
    def response
      page = response_handler.get_first_page

      if page.success?
        page.body
      elsif response_handler.respond_to?(:retryable?) && response_handler.retryable?(page.status_code)
        retried_page = attempt_retry

        retried_page.body
      else
        error_handlers.each do |handler|
          handler.call(page, self)
        end
      end
    end
  end
end
