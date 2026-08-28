#pragma once

#include <atomic>
#include <chrono>
#include <cstddef>
#include <memory>
#include <stdexcept>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <model_cpp/include/example/model/types/order_item.hpp>
#include <model_cpp/include/example/model/types/order_item_result.hpp>


namespace example::inventory_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct GetInventoryItemData final {
  GetInventoryItemData() : state_(std::make_shared<State>()) {
    state_->stock = {
        {"SKU-001", std::make_shared<std::atomic<std::int32_t>>(100)},
        {"SKU-002", std::make_shared<std::atomic<std::int32_t>>(50)},
        {"SKU-003", std::make_shared<std::atomic<std::int32_t>>(25)},
    };
  }

  template <typename Output, typename ErrorOutput>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::model::types::OrderItem& value,
                  Output&& out,
                  ErrorOutput&& errors) const {
    (void)stream;
    std::int32_t available = 0;
    bool reserved = false;
    const auto it = state_->stock.find(value.sku);
    if (it != state_->stock.end()) {
      available = it->second->load(std::memory_order_relaxed);
      while (available >= value.quantity) {
        if (it->second->compare_exchange_weak(
                available, available - value.quantity,
                std::memory_order_relaxed, std::memory_order_relaxed)) {
          reserved = true;
          break;
        }
      }
    }

    example::model::types::OrderItemResult result{
        value.order_id,
        value.item_id,
        value.sku,
        value.quantity,
        reserved ? value.quantity : available,
        reserved,
        reserved ? "CONFIRMED" : "OUT_OF_STOCK",
        value.unit_price,
        {},
    };
    if (reserved) {
      out.out(std::move(context), std::move(result));
    } else {
      errors.out(std::move(context), std::move(result));
    }
  }

 private:
  struct State final {
    std::unordered_map<
        std::string, std::shared_ptr<std::atomic<std::int32_t>>> stock;
  };

  std::shared_ptr<State> state_;
};

inline std::unique_ptr<GetInventoryItemData> MakeGetInventoryItemData(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::ProcessStreamConfig& config) {
  (void)context; (void)environment; (void)config;
  return std::make_unique<GetInventoryItemData>();
}

}  // namespace example::inventory_service::functions
