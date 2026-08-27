#include <concepts>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/endpoint/process_order_source.hpp"

namespace example::order_service::functions {

TEST(ProcessOrderSource, Contract) {
  static_assert(std::default_initializable<ProcessOrderSource>);
  GTEST_SKIP() << "TODO: add behavior assertions for ProcessOrderSource";
}

}  // namespace example::order_service::functions
