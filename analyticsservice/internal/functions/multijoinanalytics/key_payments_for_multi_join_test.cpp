#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/multijoinanalytics/key_payments_for_multi_join.hpp"

namespace example::analytics_service::functions {

TEST(KeyPaymentsForMultiJoin, Contract) {
  static_assert(std::default_initializable<KeyPaymentsForMultiJoin>);
  GTEST_SKIP() << "TODO: add behavior assertions for KeyPaymentsForMultiJoin";
}

}  // namespace example::analytics_service::functions