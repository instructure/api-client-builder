module APIClientBuilder
  class PutRequest < Request
    # Yields the response body if the response was successful. Will call
    # the response handlers if there was not a successful response.
    #
    # @return [JSON] the http response body
    def response
      response = response_handler.put_request(@body)

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
