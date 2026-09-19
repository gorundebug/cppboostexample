#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/substream_analytics_result_sink.hpp"

namespace example::analytics_service::functions {

TEST(SubstreamAnalyticsResultSink, Contract) {
  static_assert(std::default_initializable<SubstreamAnalyticsResultSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for SubstreamAnalyticsResultSink";
}

}  // namespace example::analytics_service::functions