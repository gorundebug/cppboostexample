#include <concepts>

#include <gtest/gtest.h>

#include "analyticsservice/internal/functions/joinanalytics/join_order_payment_analytics.hpp"

namespace example::analytics_service::functions {

TEST(JoinOrderPaymentAnalytics, Contract) {
  static_assert(std::default_initializable<JoinOrderPaymentAnalytics>);
  GTEST_SKIP() << "TODO: add behavior assertions for JoinOrderPaymentAnalytics";
}

}  // namespace example::analytics_service::functions