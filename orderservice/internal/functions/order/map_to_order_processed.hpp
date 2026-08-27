#pragma once

#include <chrono>
#include <cstddef>
#include <memory>

#include <algorithm>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/base.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <model/include/example/model/types/order_processed.hpp>
#include <orderservice/internal/types/order_state.hpp>


namespace example::order_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct MapToOrderProcessed final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::order_service::types::OrderState& value,
                  Output&& out) const {
    (void)stream;
    const auto confirmed_items = static_cast<std::size_t>(std::count_if(
        value.confirmed_items.begin(), value.confirmed_items.end(),
        [](const auto& item) { return item.reserved; }));
    out.out(
        std::move(context),
        example::model::types::OrderProcessed{
            value.order_id,
            value.status,
            value.processed_at,
            value.confirmed_items.size(),
            confirmed_items,
            value.status == "CONFIRMED" ? std::string{} : value.status,
        });
  }
};

inline std::unique_ptr<MapToOrderProcessed> MakeMapToOrderProcessed(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::MapStreamConfig& config) {
  (void)context;
  (void)environment;
  (void)config;
  return std::make_unique<MapToOrderProcessed>();
}

}  // namespace example::order_service::functions
