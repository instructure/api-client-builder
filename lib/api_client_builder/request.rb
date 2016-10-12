module APIClientBuilder
  class DefaultPageError < StandardError;end

  class Request
    attr_reader :type, :response_handler, :body, :error_handlers_collection

    # @param type [Symbol] defines the object type to be processed
    # @option response_handler [ResponseHandler] the response handler. Usually
    # a pagination strategy
    # @option body [Hash] the body of the response from the source
    def initialize(type, response_handler, body = {})
      @type = type
      @response_handler = response_handler
      @body = body
      @error_handlers_collection = []
    end

    # Yields the collection of error handlers that have been populated
    # via the on_error interface. If none are defined, this will provide a
    # default error handler that will provide context about the error and
    # also how to define a new error handler.
    #
    # @return [Array<Block>] the error handlers collection
    def error_handlers
      if error_handlers_collection.empty?
        self.on_error do |page, handler|
          raise DefaultPageError,
            "Default error for bad response. If you want to handle this" \
            " error use #on_error on the response" \
            " in your api consumer. Error Code: #{page.status_code}"
        end
      end
      error_handlers_collection
    end

    # Used to define custom error handling on this response.
    # The error handlers will be called if there is not a success
    #
    # @param block [Lambda] the error handling block to be stored in
    #   the error_handlers list
    def on_error(&block)
      @error_handlers_collection << block
    end

    private

    def attempt_retry
      page = response_handler.retry_request

      if page.success?
        response_handler.reset_retries
        return page
      elsif response_handler.retryable?(page.status_code)
        attempt_retry
      else
        notify_error_handlers(page)
      end
    end

    def notify_error_handlers(page)
      error_handlers.each do |handler|
        handler.call(page, self)
      end
    end
  end
end
