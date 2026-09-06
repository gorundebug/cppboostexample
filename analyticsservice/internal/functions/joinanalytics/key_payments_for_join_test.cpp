#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/joinanalytics/key_payments_for_join.hpp"

namespace example::analytics_service::functions {

TEST(KeyPaymentsForJoin, Contract) {
  static_assert(std::default_initializable<KeyPaymentsForJoin>);
  GTEST_SKIP() << "TODO: add behavior assertions for KeyPaymentsForJoin";
}

}  // namespace example::analytics_service::functions