module APIClientBuilder
  class DeleteRequest < Request
    # Yields the response body if the response was successful. Will call
    # the response handlers if there was not a successful response.
    #
    # @return [JSON] the http response body
    def response
      response = response_handler.delete_request

      if response.success?
        response
      else
        error_handlers.each do |handler|
          handler.call(response, self)
        end
      end
    end
  end
end
