#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/cycleanalytics/continue_cycle_analytics.hpp"

namespace example::analytics_service::functions {

TEST(ContinueCycleAnalytics, Contract) {
  static_assert(std::default_initializable<ContinueCycleAnalytics>);
  GTEST_SKIP() << "TODO: add behavior assertions for ContinueCycleAnalytics";
}

}  // namespace example::analytics_service::functions