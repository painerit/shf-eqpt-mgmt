require "test_helper"

class DocumentCounterTest < ActiveSupport::TestCase
  test "next_value! increments counter for kind and year" do
    first = DocumentCounter.next_value!(kind: "verification", year: 2031)
    second = DocumentCounter.next_value!(kind: "verification", year: 2031)

    assert_equal 1, first
    assert_equal 2, second
    assert_equal 2, DocumentCounter.find_by(kind: "verification", year: 2031).value
  end

  test "counter is scoped by kind and year" do
    DocumentCounter.next_value!(kind: "verification", year: 2032)
    other = DocumentCounter.next_value!(kind: "other", year: 2032)

    assert_equal 1, other
  end
end