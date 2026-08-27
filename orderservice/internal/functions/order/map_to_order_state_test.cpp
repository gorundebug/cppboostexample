#include <optional>
#include <utility>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/order/map_to_order_state.hpp"
#include "orderservice/internal/functions/test_stream.hpp"

namespace example::order_service::functions {

namespace {
struct StateCollector final {
  std::optional<example::order_service::types::OrderState> value;
  void out(servicelib::MessageContext,
           example::order_service::types::OrderState state) {
    value = std::move(state);
  }
};
}  // namespace

TEST(MapToOrderState, ProducesTimeoutState) {
  MapToOrderState function;
  StateCollector out;
  test::Stream stream;
  function(servicelib::MessageContext{}, stream,
           example::order_service::types::Order{
               "order-1", "customer-1", {}, 42.5, {}, {}},
           out);

  ASSERT_TRUE(out.value.has_value());
  EXPECT_EQ(out.value->order_id, "order-1");
  EXPECT_EQ(out.value->status, "TIMED_OUT");
  EXPECT_DOUBLE_EQ(out.value->total_amount, 42.5);
}

}  // namespace example::order_service::functions
