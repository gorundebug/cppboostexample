#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/multijoinanalytics/route_analytics_result.hpp"

namespace example::analytics_service::functions {

TEST(RouteAnalyticsResult, Contract) {
  static_assert(std::default_initializable<RouteAnalyticsResult>);
  GTEST_SKIP() << "TODO: add behavior assertions for RouteAnalyticsResult";
}

}  // namespace example::analytics_service::functions