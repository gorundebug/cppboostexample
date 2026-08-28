#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/cron/analytics_schedule_source.hpp"

namespace example::analytics_service::functions {

TEST(AnalyticsScheduleSource, Contract) {
  static_assert(std::default_initializable<AnalyticsScheduleSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for AnalyticsScheduleSource";
}

}  // namespace example::analytics_service::functions