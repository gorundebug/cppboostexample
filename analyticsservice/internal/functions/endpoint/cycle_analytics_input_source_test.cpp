#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/cycle_analytics_input_source.hpp"

namespace example::analytics_service::functions {

TEST(CycleAnalyticsInputSource, Contract) {
  static_assert(std::default_initializable<CycleAnalyticsInputSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for CycleAnalyticsInputSource";
}

}  // namespace example::analytics_service::functions