module Futureshop
  class Inventory
    class << self
      def each_batch(types: [:regular], create_date_start: nil, create_date_end: nil, product_no: [], jan_code: [])
        params = {
          types: types,
          product_no: product_no,
          jan_code: jan_code
        }
        params[:create_date_start] = create_date_start.strftime("%FT%T") if create_date_start
        params[:create_date_end] = create_date_end.strftime("%FT%T") if create_date_end
        res = client.get("/admin-api/v1/inventory", params: params)
        yield res["productList"]

        next_url = res["nextUrl"]
        while next_url
          sleep Client::INTERVAL
          url = URI.parse(next_url)
          res = client.request_by_uri(:get, url)
          yield res["productList"]
          next_url = res["nextUrl"]
        end
      end

      def each(**args)
        return enum_for(__method__, **args) unless block_given?

        each_batch **args do |inventories|
          inventories.each do |inventory|
            yield inventory
          end
        end
      end

      def all(**args)
        return each.to_a
      end

      private

      def client
        @client ||= Futureshop::Client.new(
          shop_key: ENV["FUTURESHOP_SHOP_KEY"],
          client_id: ENV["FUTURESHOP_CLIENT_ID"],
          client_secret: ENV["FUTURESHOP_CLIENT_SECRET"],
          api_domain: ENV["FUTURESHOP_API_DOMAIN"]
        )
      end
    end
  end
end
