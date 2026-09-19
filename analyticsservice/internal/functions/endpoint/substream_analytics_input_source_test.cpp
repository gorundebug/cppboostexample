#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/substream_analytics_input_source.hpp"

namespace example::analytics_service::functions {

TEST(SubstreamAnalyticsInputSource, Contract) {
  static_assert(std::default_initializable<SubstreamAnalyticsInputSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for SubstreamAnalyticsInputSource";
}

}  // namespace example::analytics_service::functions