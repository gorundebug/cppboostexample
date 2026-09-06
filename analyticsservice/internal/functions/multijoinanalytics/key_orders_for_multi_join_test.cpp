#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/multijoinanalytics/key_orders_for_multi_join.hpp"

namespace example::analytics_service::functions {

TEST(KeyOrdersForMultiJoin, Contract) {
  static_assert(std::default_initializable<KeyOrdersForMultiJoin>);
  GTEST_SKIP() << "TODO: add behavior assertions for KeyOrdersForMultiJoin";
}

}  // namespace example::analytics_service::functions