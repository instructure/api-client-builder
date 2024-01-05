module APIClientBuilder
  class NoURLError < StandardError; end
  class URLGenerator
    # Receives a domain and parses it into a URI
    #
    # @param domain [String] the domain of the API
    def initialize(domain)
      @base_uri = URI.parse(domain)
      @base_uri = URI.parse('https://' + domain) if @base_uri.scheme.nil?
      @base_uri.path << '/' unless @base_uri.path.end_with?('/')
    end

    # Defines a full API route and interpolates parameters into the route
    # provided that the parameter sent in has a key that matches the parameter
    # that is defined by the route.
    #
    # @param route [String] defines the route endpoint
    # @param params [Hash] the optional params to be interpolated into the route
    #
    # @raise [ArgumentError] if route defined param is not provided
    #
    # @return [URI] the fully built route
    def build_route(route, **params)
      string_params = route.split(%r{[\/=&]}).select { |param| param.start_with?(':') }
      symboled_params = string_params.map { |param| param.tr(':', '').to_sym }

      new_route = route.clone
      symboled_params.each do |param|
        value = params[param]
        raise ArgumentError, "Param :#{param} is required" unless value
        new_route.gsub!(":#{param}", encode_ascii(value.to_s))
      end

      @base_uri.merge(new_route)
    end

    private

    def encode_ascii(str)
      str.each_char.map do |c|
        next c if c.force_encoding('ascii').valid_encoding?
        CGI.escape c
      end.join
    end
  end
end
