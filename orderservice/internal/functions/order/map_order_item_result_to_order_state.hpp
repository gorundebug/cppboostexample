#pragma once

#include <memory>

#include <chrono>
#include <cstddef>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <string>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <model_cpp/include/example/model/types/order_item_result.hpp>
#include <orderservice/internal/types/order_state.hpp>


namespace example::order_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct MapOrderItemResultToOrderState final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::model::types::OrderItemResult& value,
                  Output&& out) const {
    (void)stream;
    out.out(
        std::move(context),
        example::order_service::types::OrderState{
            value.order_id,
            value.reserved ? "CONFIRMED" : "PARTIALLY_CONFIRMED",
            {value},
            0.0,
            nowString(),
        });
  }

 private:
  static std::string nowString() {
    const auto now = std::chrono::system_clock::to_time_t(
        std::chrono::system_clock::now());
    std::tm value{};
#if defined(_WIN32)
    gmtime_s(&value, &now);
#else
    gmtime_r(&now, &value);
#endif
    std::ostringstream output;
    output << std::put_time(&value, "%Y-%m-%dT%H:%M:%SZ");
    return output.str();
  }
};

inline std::unique_ptr<MapOrderItemResultToOrderState> MakeMapOrderItemResultToOrderState(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::MapStreamConfig& config) {
  (void)context; (void)environment; (void)config;
  return std::make_unique<MapOrderItemResultToOrderState>();
}

}  // namespace example::order_service::functions
