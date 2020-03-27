module APIClientBuilder
  # The base APIClient that defines the interface for defining an API Client.
  # Should be sub-classed and then provided an HTTPClient handler and a
  # response handler.
  class APIClient
    attr_reader :url_generator, :http_client

    # @param opts [Hash] options hash
    # @option opts [Symbol] :http_client The http client handler
    # @option opts [Symbol] :paginator The response handler
    def initialize(**opts)
      @url_generator = APIClientBuilder::URLGenerator.new(opts[:domain])
      @http_client = opts[:http_client]
    end

    # Used to define a GET api route on the base class. Will
    # yield a method that takes the shape of 'get_type' that will
    # return a CollectionResponse or ItemResponse based on plurality.
    #
    # @param type [Symbol] defines the route model
    # @param plurality [Symbol] defines the routes plurality
    # @param route [String] defines the routes endpoint
    #
    # @return [Request] either a GetCollection or GetItem request
    def self.get(type, plurality, route, **_opts)
      if plurality == :collection
        define_method("get_#{type}") do |**params|
          GetCollectionRequest.new(
            type,
            response_handler_build(http_client, @url_generator.build_route(route, **params), type)
          )
        end
      elsif plurality == :singular
        define_method("get_#{type}") do |**params|
          GetItemRequest.new(
            type,
            response_handler_build(http_client, @url_generator.build_route(route, **params), type)
          )
        end
      end
    end

    # Used to define a POST api route on the base class. Will
    # yield a method that takes the shape of 'post_type' that will
    # return a PostRequest.
    #
    # @param type [Symbol] defines the route model
    # @param route [String] defines the routes endpoint
    #
    # @return [PostRequest] the request object that handles posts
    def self.post(type, route)
      define_method("post_#{type}") do |body, **params|
        PostRequest.new(
          type,
          response_handler_build(http_client, @url_generator.build_route(route, **params), type),
          body
        )
      end
    end

    # Used to define a PUT api route on the base class. Will
    # yield a method that takes the shape of 'put_type' that will
    # return a PutRequest.
    #
    # @param type [Symbol] defines the route model
    # @param route [String] defines the routes endpoint
    #
    # @return [PutRequest] the request object that handles puts
    def self.put(type, route)
      define_method("put_#{type}") do |body, **params|
        PutRequest.new(
          type,
          response_handler_build(http_client, @url_generator.build_route(route, **params), type),
          body
        )
      end
    end

    # Used to define a DELETE api route on the base class. Will
    # yield a method that takes the shape of 'delete_type' that will
    # return a DeleteRequest.
    #
    # @param type [Symbol] defines the route model
    # @param route [String] defines the routes endpoint
    #
    # @return [DeleteRequest] the request object that handles puts
    def self.delete(type, route)
      define_method("delete_#{type}") do |**params|
        DeleteRequest.new(
          type,
          response_handler_build(http_client, @url_generator.build_route(route, **params), type)
        )
      end
    end
  end
end
