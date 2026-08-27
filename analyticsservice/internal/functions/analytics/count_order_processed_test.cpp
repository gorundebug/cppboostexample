#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/analytics/count_order_processed.hpp"

namespace example::analytics_service::functions {

TEST(CountOrderProcessed, Contract) {
  static_assert(std::default_initializable<CountOrderProcessed>);
  GTEST_SKIP() << "TODO: add behavior assertions for CountOrderProcessed";
}

}  // namespace example::analytics_service::functions
