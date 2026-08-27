#include <concepts>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/endpoint/process_order_item_sink.hpp"

namespace example::order_service::functions {

TEST(ProcessOrderItemSink, Contract) {
  static_assert(std::default_initializable<ProcessOrderItemSink>);
  GTEST_SKIP() << "TODO: add behavior assertions for ProcessOrderItemSink";
}

}  // namespace example::order_service::functions
