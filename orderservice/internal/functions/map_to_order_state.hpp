#pragma once

#include <memory>

#include <chrono>
#include <cstddef>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <orderservice/internal/types/order.hpp>
#include <orderservice/internal/types/order_state.hpp>


namespace example::order_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct MapToOrderState final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::order_service::types::Order& value,
                  Output&& out) const {
    (void)stream;
    out.out(
        std::move(context),
        example::order_service::types::OrderState{
            value.id,
            "TIMED_OUT",
            {},
            value.total_amount,
            {},
        });
  }
};

inline std::unique_ptr<MapToOrderState> MakeMapToOrderState(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::MapStreamConfig& config) {
  (void)context; (void)environment; (void)config;
  return std::make_unique<MapToOrderState>();
}

}  // namespace example::order_service::functions
