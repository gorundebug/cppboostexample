#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/substreamanalytics/invoke_analytics_substream.hpp"

namespace example::analytics_service::functions {

TEST(InvokeAnalyticsSubstream, Contract) {
  static_assert(std::default_initializable<InvokeAnalyticsSubstream>);
  GTEST_SKIP() << "TODO: add behavior assertions for InvokeAnalyticsSubstream";
}

}  // namespace example::analytics_service::functions