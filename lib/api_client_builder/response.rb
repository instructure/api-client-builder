module APIClientBuilder
  # The default page object to be used to hold the response from the API
  # in your response handler object. Any response object that will replace this
  # must response to #success?, and #items
  class Response
    attr_accessor :body, :status_code

    # @param body [String/Array/Hash] the response body
    # @param status_code [Integer] the response status code
    # @param success_range [Array<Integer>] the success range of this response
    def initialize(body, status_code, success_range)
      @body = body
      @status_code = status_code
      @success_range = success_range
      @failed_reason = nil
    end

    # Used to mark why the response failed
    def mark_failed(reason)
      @failed_reason = reason
    end

    # Defines the success conditional for a response by determining whether
    # or not the status code of the response is within the defined success
    # range
    #
    # @return [Boolean] whether or not the response is a success
    def success?
      @failed_reason.nil? && @success_range.include?(@status_code)
    end
  end
end
