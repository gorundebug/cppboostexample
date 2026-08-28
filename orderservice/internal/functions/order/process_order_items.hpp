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
#include <model_cpp/include/example/model/types/order_item.hpp>
#include <orderservice/internal/types/order.hpp>


namespace example::order_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct ProcessOrderItems final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::order_service::types::Order& value,
                  Output&& out) const {
    (void)stream;
    for (auto item : value.items) {
      item.order_id = value.id;
      out.out(context, std::move(item));
    }
  }
};

inline std::unique_ptr<ProcessOrderItems> MakeProcessOrderItems(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::FlatMapStreamConfig& config) {
  (void)context; (void)environment; (void)config;
  return std::make_unique<ProcessOrderItems>();
}

}  // namespace example::order_service::functions
