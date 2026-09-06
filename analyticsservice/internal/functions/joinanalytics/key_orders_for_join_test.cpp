#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/joinanalytics/key_orders_for_join.hpp"

namespace example::analytics_service::functions {

TEST(KeyOrdersForJoin, Contract) {
  static_assert(std::default_initializable<KeyOrdersForJoin>);
  GTEST_SKIP() << "TODO: add behavior assertions for KeyOrdersForJoin";
}

}  // namespace example::analytics_service::functions