require_relative "futureshop/version"
require_relative "futureshop/client"

module Futureshop
  class Error < StandardError; end

  class << self
    attr_writer :client

    def orders(format: "json", **options)
      require "csv" if format == "csv"

      client.each_order(**options).with_index do |row, index|
        sleep 1 unless ENV["NO_THROTTLE"] # FIXME: Delegate to client
        order = client.order(row["orderNo"])
        case format
        when "json"
          puts order.to_json
        when "csv"
          headers = []
          CSV $stdout do |csv|
            if index == 0
              csv << aggregate_headers(order)
            end
            raise "Multiple shipmentList. orderNo: #{order["orderNo"]}" if order["shipmentList"].length > 1
            order["shipmentList"].each do |shipment|
              shipment["productList"].each do |product|
                csv << order.each_pair.with_object([]) {|(key, value), values|
                  case value
                  when Hash
                    value.each_value do |v|
                      values << v
                    end
                  when Array
                    case key
                    when "shipmentList"
                      # shipmentList's length is 1
                      shipment.each_value do |v|
                        case v
                        when Hash
                          v.each_value do |ov|
                            values << ov
                          end
                        when Array
                          product.each_pair do |k, v|
                            case k
                            when "optionPriceList"
                              v = v.collect {|optionPrice| "#{optionPrice['name']}:#{optionPrice['selectionName']}(#{optionPrice['price']})"}.join("/")
                            when "optionList"
                              v = v.collect {|option| [option["name"], option["selectionItem"]].join(":")}.join(",")
                            end
                            values << v
                          end
                        else
                          values << v
                        end
                      end
                    when "couponList"
                      values << value.collect {|coupon| [coupon["id"], coupon["name"]].join(":")}.join("/")
                    else
                      raise "Unknown array field: #{key}"
                    end
                  else
                    values << value
                  end
                }
              end
            end
          end
        else
          raise RuntimeError("unsupported format: #{format}")
        end
      end
    end

    def client
      @client ||= Futureshop::Client.new(
        shop_key: ENV["FUTURESHOP_SHOP_KEY"],
        client_id: ENV["FUTURESHOP_CLIENT_ID"],
        client_secret: ENV["FUTURESHOP_CLIENT_SECRET"],
        api_domain: ENV["FUTURESHOP_API_DOMAIN"]
      )
    end

    private

    def aggregate_headers(obj, headers = [])
      obj.each_pair do |key, value|
        unless %w[buyerInfo addressInfo shippingInfo shipmentList productList].include? key
          headers << key
        end
        case value
        when Hash
          headers.concat aggregate_headers(value).collect {|header| "#{key}.#{header}"}
        when Array
          next if key == "couponList"
          sample = value[0]
          if sample
            headers.concat aggregate_headers(sample).collect {|header| "#{key}.#{header}"}
          end
        end
      end
      headers
    end
  end
end
