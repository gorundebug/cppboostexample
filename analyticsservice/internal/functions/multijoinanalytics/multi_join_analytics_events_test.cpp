#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/multijoinanalytics/multi_join_analytics_events.hpp"

namespace example::analytics_service::functions {

TEST(MultiJoinAnalyticsEvents, Contract) {
  static_assert(std::default_initializable<MultiJoinAnalyticsEvents>);
  GTEST_SKIP() << "TODO: add behavior assertions for MultiJoinAnalyticsEvents";
}

}  // namespace example::analytics_service::functions