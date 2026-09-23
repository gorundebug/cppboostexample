#pragma once

#include <chrono>
#include <cstddef>
#include <memory>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <boost/asio/awaitable.hpp>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/base.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <inventoryservice/internal/types/inventory_failure.hpp>
#include <example/model/types/order_item_result.hpp>


namespace example::inventory_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct GetInventoryItemError final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::inventory_service::types::InventoryFailure& value,
                  Output&& out) const {
    (void)stream;
    const auto& item = value.item;
    out.out(std::move(context), example::model::types::OrderItemResult{
        item.order_id, item.item_id, item.sku, item.quantity,
        value.available_qty, false, "OUT_OF_STOCK", item.unit_price,
        "inventory is out of stock"});
  }
};

inline boost::asio::awaitable<std::unique_ptr<GetInventoryItemError>> MakeGetInventoryItemError(
    servicelib::Context context, servicelib::IServiceEnvironment& environment) {
  (void)context;
  (void)environment;

  co_return std::make_unique<GetInventoryItemError>();
}

}  // namespace example::inventory_service::functions
