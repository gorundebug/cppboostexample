#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/high_value_analytics_sink.hpp"

namespace example::analytics_service::functions {

TEST(HighValueAnalyticsSink, Contract) {
  static_assert(std::default_initializable<HighValueAnalyticsSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for HighValueAnalyticsSink";
}

}  // namespace example::analytics_service::functions