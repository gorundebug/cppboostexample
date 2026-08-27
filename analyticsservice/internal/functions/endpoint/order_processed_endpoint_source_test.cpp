#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/order_processed_endpoint_source.hpp"

namespace example::analytics_service::functions {

TEST(OrderProcessedEndpointSource, Contract) {
  static_assert(std::default_initializable<OrderProcessedEndpointSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for OrderProcessedEndpointSource";
}

}  // namespace example::analytics_service::functions
