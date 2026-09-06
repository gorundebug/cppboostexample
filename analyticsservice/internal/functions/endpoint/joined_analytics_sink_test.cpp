#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/joined_analytics_sink.hpp"

namespace example::analytics_service::functions {

TEST(JoinedAnalyticsSink, Contract) {
  static_assert(std::default_initializable<JoinedAnalyticsSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for JoinedAnalyticsSink";
}

}  // namespace example::analytics_service::functions