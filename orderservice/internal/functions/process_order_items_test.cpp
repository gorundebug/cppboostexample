#include <utility>
#include <vector>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/process_order_items.hpp"
#include "orderservice/internal/functions/test_stream.hpp"

namespace example::order_service::functions {

namespace {
struct ItemCollector final {
  std::vector<example::model::types::OrderItem> values;
  void out(servicelib::MessageContext,
           example::model::types::OrderItem value) {
    values.push_back(std::move(value));
  }
};
}  // namespace

TEST(ProcessOrderItems, EmitsEveryItemWithParentOrderId) {
  ProcessOrderItems function;
  ItemCollector out;
  test::Stream stream;
  function(
      servicelib::MessageContext{},
      stream,
      example::order_service::types::Order{
          "order-1",
          "customer-1",
          {
              {"stale", "item-1", "SKU-001", 2, 3.5},
              {"stale", "item-2", "SKU-002", 1, 7.0},
          },
          14.0,
          {},
          {},
      },
      out);

  ASSERT_EQ(out.values.size(), 2);
  EXPECT_EQ(out.values[0].order_id, "order-1");
  EXPECT_EQ(out.values[1].order_id, "order-1");
  EXPECT_EQ(out.values[0].item_id, "item-1");
  EXPECT_EQ(out.values[1].item_id, "item-2");
}

}  // namespace example::order_service::functions
