#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/endpoint/analytics_shipments_source.hpp"

namespace example::analytics_service::functions {

TEST(AnalyticsShipmentsSource, Contract) {
  static_assert(std::default_initializable<AnalyticsShipmentsSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for AnalyticsShipmentsSource";
}

}  // namespace example::analytics_service::functions