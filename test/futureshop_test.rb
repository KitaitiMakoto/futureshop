require_relative "helper"

class FutureshopTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Futureshop.const_defined?(:VERSION)
    end
  end

  test "client" do
    client = Futureshop::Client.new(
      shop_key: "cctest21050207",
      client_id: "fs-client.21e94d721e634b0483e2436bb4c13260",
      client_secret: "9u6mta9g34u7nc4ec3s432ttedoihuqnrg3v3f3zvzmj1iv7ot69a74dwypuaauu",
      api_domain: "api.admin.future-shop.net:8083"
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
end
