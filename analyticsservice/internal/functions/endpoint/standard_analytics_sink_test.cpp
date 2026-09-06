#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/standard_analytics_sink.hpp"

namespace example::analytics_service::functions {

TEST(StandardAnalyticsSink, Contract) {
  static_assert(std::default_initializable<StandardAnalyticsSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for StandardAnalyticsSink";
}

}  // namespace example::analytics_service::functions