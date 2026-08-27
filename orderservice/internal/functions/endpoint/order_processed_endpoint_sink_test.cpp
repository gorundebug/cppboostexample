#include <concepts>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/endpoint/order_processed_endpoint_sink.hpp"

namespace example::order_service::functions {

TEST(OrderProcessedEndpointSink, Contract) {
  static_assert(std::default_initializable<OrderProcessedEndpointSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for OrderProcessedEndpointSink";
}

}  // namespace example::order_service::functions
