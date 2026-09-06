#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/analytics_orders_source.hpp"

namespace example::analytics_service::functions {

TEST(AnalyticsOrdersSource, Contract) {
  static_assert(std::default_initializable<AnalyticsOrdersSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for AnalyticsOrdersSource";
}

}  // namespace example::analytics_service::functions