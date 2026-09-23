#pragma once

#include <cstdint>
#include <example/model/types/order_item.hpp>

namespace example::inventory_service::types {
struct InventoryFailure final {
  example::model::types::OrderItem item;
  std::int32_t available_qty{};
};
}  // namespace example::inventory_service::types
