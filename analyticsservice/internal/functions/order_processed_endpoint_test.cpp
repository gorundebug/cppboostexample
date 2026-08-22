#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/order_processed_endpoint.hpp"

namespace example::analytics_service::functions {

TEST(OrderProcessedEndpoint, Contract) {
  static_assert(std::default_initializable<OrderProcessedEndpoint>);
  GTEST_SKIP() << "TODO: add behavior assertions for OrderProcessed";
}

}  // namespace example::analytics_service::functions
