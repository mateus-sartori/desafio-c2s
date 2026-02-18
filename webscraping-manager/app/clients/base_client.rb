class BaseClient
  attr_reader :conn

  def self.call(*args, **kwargs, &block)
    client = new
    client.call(*args, **kwargs)
    return yield(client) if block_given?
    client
  end

  def call(base_url:)
    @conn = Faraday.new(url: base_url) do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
      faraday.options.timeout = 8
      faraday.options.open_timeout = 3
    end
  end
end
