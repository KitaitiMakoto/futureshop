require_relative "helper"

class FutureshopTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Futureshop.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "actual")
  end
end
