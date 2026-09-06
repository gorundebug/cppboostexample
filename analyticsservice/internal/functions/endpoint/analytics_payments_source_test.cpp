#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/analytics_payments_source.hpp"

namespace example::analytics_service::functions {

TEST(AnalyticsPaymentsSource, Contract) {
  static_assert(std::default_initializable<AnalyticsPaymentsSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for AnalyticsPaymentsSource";
}

}  // namespace example::analytics_service::functions