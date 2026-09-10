#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/cycle_analytics_result_sink.hpp"

namespace example::analytics_service::functions {

TEST(CycleAnalyticsResultSink, Contract) {
  static_assert(std::default_initializable<CycleAnalyticsResultSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for CycleAnalyticsResultSink";
}

}  // namespace example::analytics_service::functions