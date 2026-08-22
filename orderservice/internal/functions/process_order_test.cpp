#include <gtest/gtest.h>

#include "orderservice/internal/functions/process_order.hpp"

namespace example::order_service::functions {

namespace {
struct StreamContext final {};
}  // namespace

TEST(ProcessOrder, CorrelatesStatesByOrderId) {
  ProcessOrder function;
  StreamContext stream;
  ProcessOrder::State state;
  const auto id = function.getMessageId(
      servicelib::MessageContext{}, stream, state,
      example::order_service::types::OrderState{
          "order-9", "CONFIRMED", {}, 0.0, {}});
  EXPECT_EQ(id, "order-9");
}

TEST(ProcessOrder, EndRequestCancelsOutstandingGraphBranches) {
  ProcessOrder function;
  StreamContext stream;
  ProcessOrder::State state{std::make_shared<ProcessOrder::SharedState>()};
  const auto token = state.shared->cancel.get_token();
  servicelib::http::Request request;
  servicelib::http::Response response;
  servicelib::datasource::http::HandlerData data{request, response, {}};

  function.endRequest(servicelib::MessageContext{}, stream, {}, state, data);

  EXPECT_TRUE(token.stop_requested());
}

}  // namespace example::order_service::functions
