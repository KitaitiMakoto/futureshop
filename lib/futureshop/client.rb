require "uri"
require "net/http"
require "json"

module Futureshop
  class Client
    INTERVAL = 1

    def initialize(shop_key:, client_id:, client_secret:, api_domain:)
      @shop_key = shop_key
      @client_id = client_id
      @client_secret = client_secret
      host, port = api_domain.split(":")
      @api_domain = host
      @port = port
    end

    def authorization
      authorize
      @authorization
    end

    def authorize
      authorized_at = Time.now
      return if @authorization && authorized_at < @authorization[:expires_at]
      uri = URI::HTTPS.build(host: @api_domain, port: @port, path: "/oauth/token")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@client_id, @client_secret)
      request["X-SHOP-KEY"] = @shop_key
      request.form_data = {"grant_type" => "client_credentials"}
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) {|http|
        http.request(request)
      }
      response.value
      auth = JSON.parse(response.body)
      token_type = auth["token_type"]
      raise "Unknown token_type: #{token_type}" if token_type == "bearer"
      @authorization = {
        access_token: auth["access_token"],
        token_type: token_type,
        expires_at: authorized_at + auth["expires_in"]
      }
    end

    def request(method, path = "/", params: {}, data: {})
      raise "Unsupported method: #{method}" unless [:get, :post].include?(method)
      query = params.empty? ? nil : build_query(params)
      uri = URI::HTTPS.build(host: @api_domain, port: @port, path: path, query: query)
      request = Net::HTTP.const_get(method.capitalize).new(uri)
      headers.each_pair do |field, value|
        request[field] = value
      end
      request.body = data.to_json unless data.empty?
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) {|http| http.request(request)}
      response.value
      JSON.parse(response.body)
    end

    def get(path = "/", params: {})
      request(:get, path, params: params)
    end

    def post(path = "/", data: {})
      request(:post, path, data: data)
    end

    def orders_batch(order_date_start: nil, order_date_end: nil, order_no: [], shipping_status: nil, payment_status: nil)
      raise "shipping_status must be nil, \"notShipped\" or \"shipped\" but given #{shipping_status.dump}" unless [nil, "notShipped", "shipped"].include?(shipping_status)
      raise "payment_status must be nil, \"notReceived\" or \"received\" but given #{shipping_status.dump}" unless [nil, "notReceived", "received"].include?(payment_status)
      params = {
        shipping_status: shipping_status,
        payment_status: payment_status
      }
      params[:order_date_start] = order_date_start.strftime("%FT%T") if order_date_start
      params[:order_date_end] = order_date_end.strftime("%FT%T") if order_date_end
      params[:order_no] = order_no unless order_no.empty?

      res = get("/admin-api/v1/shipping", params: params)
      yield res["orderList"]

      next_url = res["nextUrl"]
      while next_url
        sleep INTERVAL
        res = get(next_url, params: params) # TODO: check spec to see whether it's okay to pass params in this form
        yield res["orderList"]
        next_url = res["nextUrl"]
      end
    end

    # @see +orders_batch+
    def each_order(**args)
      return self.enum_for(__method__, **args) unless block_given?

      orders_batch **args do |orders|
        orders.each do |order|
          yield order
        end
      end
    end

    # @see +orders_batch+
    def orders(**args)
      return each_order.to_a
    end

    def order(order_no)
      get("/admin-api/v1/orders/#{URI.encode_www_form_component(order_no)}")
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "X-SHOP-KEY" => @shop_key,
        "Authorization" => "Bearer #{authorization[:access_token]}"
      }
    end

    def build_query(params)
      params.each_with_object("") {|(field, value), query|
        next if value.nil?
        next if value.empty?
        query << "&" unless query.empty?
        words = field.to_s.split("_")
        field = words[0] + words[1..].collect(&:capitalize).join("")
        field = URI.encode_www_form_component(field)
        value = value.respond_to?(:join) ? value.collect {|v| URI.encode_www_form_component(v)}.join(",") : value
        query << "#{field}=#{value}"
      }
    end
  end
end
