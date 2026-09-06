#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/multijoinanalytics/key_shipments_for_multi_join.hpp"

namespace example::analytics_service::functions {

TEST(KeyShipmentsForMultiJoin, Contract) {
  static_assert(std::default_initializable<KeyShipmentsForMultiJoin>);
  GTEST_SKIP() << "TODO: add behavior assertions for KeyShipmentsForMultiJoin";
}

}  // namespace example::analytics_service::functions