# API Client Builder

API Client Builder was created to reduce the overhead of creating API clients.

It provides a DSL for defining endpoints and only requires you to define handlers
for HTTP requests and responses.

[![Build Status](https://travis-ci.org/instructure/api-client-builder.svg?branch=master)](https://travis-ci.org/instructure/api-client-builder)

---

## Installation

Add this line to your application's Gemfile:

    gem 'api_client_builder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_client_builder

---

## Defining a client

The basic client structure looks like this.

```ruby
class Client < APIClientBulder::APIClient
  def initialize(**opts)
    super(domain: opts[:domain],
          http_client: HTTPClientHandler)
  end
end
```

The client requires a response handler to be defined in the following method.
Unlike the HTTPClientHandler that can be sent in as a reference to a class
and instantiated, the response handler has a few extra options that must
be defined concretely on a per-client basis.

Exponential back-off is optional for handling retries of requests. If unset,
the builder will ignore it and will resort to just calling error handlers
upon failure.

```ruby
def response_handler_build(http_client, start_url, type)
  ResponseHandler.new(http_client, start_url, type, exponential_backoff: true)
end
```

### Defining routes on the client

To define routes on the api client, use the DSL provided by the
builder's APIClient class. Four parts have been defined to help:

1) Action - `#get`, `#post`, or `#put`:  will define the HTTP action and the first part
  of the defined method.

2) Resource Type:  will define the "type" of the route and finishes out the
  defined method "get_resource_type".
  - Note that this portion of the route has a special property
  that allows you to add `_for_something_else` to the end while maintaining
  everything before the "for" as the "type" that is sent back. This is helpful when
  parsing the responses because you might want to get "students" for say "schools",
  and "courses", and "sections", where the response object type is "students" for
  all three routes.

3) Plurality - `:singular`, `:collection`:  determines whether
  or not the response will be a single object or multiple to know whether or
  not pagination is required.
  - Note that "put" and "post" don't need plurality defined

4) Route:  defines the route to be appended to the provided domain.
  - Note that any symbols in the route will be interpolated as required
   params when calling the method on the client.

---

## Route Examples

#### Single Item Gets: Yields GetItemRequest

Define the route on the client

```ruby
get :some_object, :singular, 'some_objects/:id'
```

Use the defined route

```ruby
single_request = client.get_some_object(id: 123)

response_body = single_request.response
```

#### Collection Item Gets: Yields GetCollectionRequest

Define the route on the client

```ruby
get :some_objects, :collection, 'some_objects'
```

Use the defined route

```ruby
collection_request = client.get_some_objects

collection_request.each do |item|
  # Item will be a Hash if you use the default response in the response handler
end
```

#### Put Item: Yields PutRequest

Define the route on the client

```ruby
put :some_object, 'some_objects/:id'
```

Use the defined route (Takes a hash/JSON as the first arg)

```ruby
request = client.put_some_object({}, id: 123)

response_body = request.response
```

#### Collection Item Gets: Yields PostRequest

Define the route on the client

```ruby
post :some_objects, 'some_objects'
```

Use the defined route (Takes a hash/JSON as the first arg)

```ruby
request = client.post_some_object({})

response_body = request.response
```

#### Multiple routes for same object

All of these routes will yield a collection with type "some_objects"

```ruby
get :some_objects, :collection, 'some_objects'
get :some_objects_for_school, :collection, 'school/:school_id/some_objects'
get :some_objects_for_course, :collection, 'course/:course_id/some_objects'
```

---

## Defining an HTTP Client Handler

The HTTP Client Handler is designed to manage the HTTP requests themselves. Since
actually making an HTTP request typically requires some amount of authentication,
it is suggested that authentication and headers are managed here as well.

The HTTP client handler requires '#get', '#post', and '#put' to be defined here
with the shown method signature.

```ruby
class HTTPClientHandler
  # Do initialization here, generally authentication creds and a domain is sent in

  def get(route, params = nil, headers = {})
    client.get(route, params, headers)
  end

  def put(route, params = nil, headers = {})
    client.put(route, params, headers)
  end

  def post(route, params = nil, headers = {})
    client.post(route, params, headers)
  end

  # Define a client to use here. The HTTPClient gem is a good option

  # Build up headers and authentication handling here as well
end
```

---

## Defining a Response Handler

The response handler is where everything comes together. As the name suggests,
defining how to get responses but also how to handle them is done here.

Define only the methods that match the requests that the client needs. For
simpler API's this considerably reduces the overhead of setting up the response
handler.

Through the methods defined here the builder will manage how requests are handled.
When defining the response handler, in general, a start url and an http_client_handler
is provided to the initializer. Since most API's send the "type" as the top level key,
the `#response_handler_build` that was defined in the client receives that type
as a parameter. It is used to extract the actual body from the response
as well. Furthermore, feel free to send any other options required to make
these actions simpler.

  - Note: `#build_response` will be used in all examples and explained once
  all required methods are defined

```ruby
class ResponseHandler
  def initialize(http_client_handler, start_url, type)
    @http_client = http_client_handler
    @start_url = start_url
    @type = type
  end
end
```

---

## Response Handler Examples

#### For single gets

The builder will only call `#get_first_page` when handling `:singular` for get routes.
If pagination is required this is a good place to figure out the number
of pages and also start the page counter.

```ruby
def get_first_page
  # Build the URL -- this could be to add pagination params to the route, or
  # add whatever else is necessary to the route.
  http_response = @http_client.get("a URL")

  # Generally the first page will contain information about how many pages a
  # paginated response will have. Set that here: `@max_pages`
  # Be sure to set the current page count as well: `@current_page`
  build_response(http_response)
end
```

#### For collection gets

The builder will call `#get_next_page` when handling `:collection` for get routes. It will
determine whether or not there are more pages by calling `#more_pages?` which must
return a boolean denoting the presence of more pages.

```ruby
def get_next_page
  # Build the URL -- this could be to add pagination params to the route, or
  # add whatever else is necessary to the route:
  http_response = @http_client.get("a URL")

  # If the http_response is valid then increment the page counter here.
  build_response(http_response)
end

def more_pages?
  @current_page < @max_pages
end
```

#### For puts

The builder will call `#put_request` when handling put routes.

```ruby
def put_request
  # Build the URL -- this could be to add pagination params to the route, or
  # add whatever else is necessary to the route.
  # Also send the body if thats how the client handler is configured.
  http_response = @http_client.put("a URL", {})
  build_response(http_response)
end
```

#### For posts

The builder will call `#post_request` when handling post routes.

```ruby
def post_request
  # Build the URL -- this could be to add pagination params to the route, or
  # add whatever else is necessary to the route.
  # Also send the body if that's how the client handler is configured.
  http_response = @http_client.post("a URL", {})
  build_response(http_response)
end
```

#### Handling retry-able requests

If requests defined need to be retry-able, extend the response handler by providing
the following methods.

```ruby
def retryable?(status_code)
  if @opts[:exponential_backoff]
    # Define the conditions of whether or not the provided status code is retry-able
    true 
  else
    false
  end
end

def reset_retries
  # Track the number of retries so the request is not retried indefinitely.
  # The builder will reset them when it no longer is retrying by calling this
  # method.
  @retries = 0
end

def retry_request
  # Increment the retries here so the request is not retried indefinitely.
  @retries += 1

  # Build the URL -- this could be to add pagination params to the route, or
  # add whatever else is necessary to the route.
  response = @http_client.the_action_to_retry("a URL")
  build_response(response)
end
```

#### Managing the HTTP response

The builder defines a default `Response` object that will provide the minimally
required interface for managing an HTTP response.

```ruby
def build_response(http_response)
  items = JSON.parse(http_response.body)

  status = http_response.status

  APIClientBuilder::Response.new(items, status, SUCCESS_RANGE)
end
```

The block above is the simplest use case for using the built-in `Response` object.
If a custom `Response` is required, define `#success?` and it will comply with
the builders contract with that object.

---

## Error handling

All requests made with the client will return a `Request` object of whatever type
of action that it was defined as. All `Request` objects will have a default error
handler defined, which will give you minimal insight into the issue and also
describe how to define a new error handler.

The actual request is not made until you call the `Request` response interface
either by `#each` or `#response`. Define an error handler before accessing the
response if custom error handling is required. Any number of error handlers
can be defined on a single request and will be called as soon as the response
is not a "success."

  - Note that the error handlers will be ignored if you opted into retry-able
  requests until the retry loop results in a success or completes its iterations.

```ruby
single_request = client.get_some_object(id: 123)

single_request.on_error do |page, handler|
  # The page will have all of the status information.
  # The handler is the defined response_handler.
  # Use either to glean more information about why the request was an error and
  # handle the error here.
end

response_body = single_request.response
```

---

## License

API Client Builder is released under the MIT License.
