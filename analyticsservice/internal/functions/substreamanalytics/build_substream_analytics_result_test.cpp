#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/substreamanalytics/build_substream_analytics_result.hpp"

namespace example::analytics_service::functions {

TEST(BuildSubstreamAnalyticsResult, Contract) {
  static_assert(std::default_initializable<BuildSubstreamAnalyticsResult>);
  GTEST_SKIP() << "TODO: add behavior assertions for BuildSubstreamAnalyticsResult";
}

}  // namespace example::analytics_service::functions