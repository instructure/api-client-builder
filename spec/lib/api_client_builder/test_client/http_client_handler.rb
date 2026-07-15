# frozen_string_literal: true

module TestClient
  class HTTPClientHandler
    def initialize(domain)
      @domain = domain
    end

    def get(route, params = nil, headers = {}); end
  end
end
