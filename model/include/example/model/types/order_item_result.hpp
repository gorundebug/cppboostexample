#pragma once

#include <boost/json.hpp>

#include <cstdint>
#include <string>

namespace example::model::types {

struct OrderItemResult final {
  std::string order_id;
  std::string item_id;
  std::string sku;
  std::int32_t requested_qty{0};
  std::int32_t available_qty{0};
  bool reserved{false};
  std::string status;
  double unit_price{0.0};
  std::string error;
};

inline void tag_invoke(boost::json::value_from_tag, boost::json::value& json,
                       const OrderItemResult& value) {
  json = {{"order_id", value.order_id},
          {"item_id", value.item_id},
          {"sku", value.sku},
          {"requested_qty", value.requested_qty},
          {"available_qty", value.available_qty},
          {"reserved", value.reserved},
          {"status", value.status},
          {"unit_price", value.unit_price},
          {"error", value.error}};
}

inline OrderItemResult tag_invoke(boost::json::value_to_tag<OrderItemResult>,
                                  const boost::json::value& json) {
  const auto& object = json.as_object();
  const auto* error = object.if_contains("error");
  return {boost::json::value_to<std::string>(object.at("order_id")),
          boost::json::value_to<std::string>(object.at("item_id")),
          boost::json::value_to<std::string>(object.at("sku")),
          boost::json::value_to<std::int32_t>(object.at("requested_qty")),
          boost::json::value_to<std::int32_t>(object.at("available_qty")),
          boost::json::value_to<bool>(object.at("reserved")),
          boost::json::value_to<std::string>(object.at("status")),
          boost::json::value_to<double>(object.at("unit_price")),
          error ? boost::json::value_to<std::string>(*error) : std::string{}};
}

}  // namespace example::model::types
