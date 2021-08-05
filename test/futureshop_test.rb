require_relative "helper"

class FutureshopTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Futureshop.const_defined?(:VERSION)
    end
  end

  test "client" do
    client = Futureshop::Client.new(
      shop_key: "dummyshopkey",
      client_id: "fs-client.dummy",
      client_secret: "dummy",
      api_domain: "api.admin.future-shop.net"
    )

    stub(client).authorize
    stub(client).get("/admin-api/v1/shipping", params: {shipping_status: nil, payment_status: nil}) {
      JSON.parse(File.read(File.join(__dir__, "./fixtures/orders.json")))
    }
    stub(client).get("/admin-api/v1/orders/100000020732") {
      JSON.parse(File.read(File.join(__dir__, "./fixtures/order.json")))
    }

    orders = client.each_order.to_a
    assert_equal(orders.length, 20)

    order = client.order("100000020732")
    assert_equal order["orderNo"], "100000020732"
    assert_equal order["shipmentList"][0]["productList"][0]["productNo"], "gd4"
  end

  test "orders" do
    Futureshop.client = Futureshop::Client.new(
      shop_key: "dummyshopkey",
      client_id: "fs-client.dummy",
      client_secret: "dummy",
      api_domain: "api.admin.future-shop.net"
    )
    client_stub = stub(Futureshop.client)
    client_stub.each_order {
      JSON.parse(File.read(File.join(__dir__, "./fixtures/orders.json")))["orderList"].each
    }
    client_stub.order {
      JSON.parse(File.read(File.join(__dir__, "./fixtures/order.json")))
    }

    lines = []
    stub($stdout).<< {|line|
      lines << line
    }

    ENV["NO_THROTTLE"] = "1"
    Futureshop.orders(format: "csv")
    ENV.delete "NO_THROTTLE"
    assert_equal lines.length, 21
  end
end
