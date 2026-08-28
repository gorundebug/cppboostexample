#pragma once

#include <boost/json.hpp>

#include <cstdint>
#include <string>

namespace example::model::types {

struct OrderItem final {
  std::string order_id;
  std::string item_id;
  std::string sku;
  std::int32_t quantity{0};
  double unit_price{0.0};
};

inline void tag_invoke(boost::json::value_from_tag, boost::json::value& json,
                       const OrderItem& value) {
  json = {{"order_id", value.order_id}, {"item_id", value.item_id},
          {"sku", value.sku}, {"quantity", value.quantity},
          {"unit_price", value.unit_price}};
}

inline OrderItem tag_invoke(boost::json::value_to_tag<OrderItem>,
                            const boost::json::value& json) {
  const auto& object = json.as_object();
  return {boost::json::value_to<std::string>(object.at("order_id")),
          boost::json::value_to<std::string>(object.at("item_id")),
          boost::json::value_to<std::string>(object.at("sku")),
          boost::json::value_to<std::int32_t>(object.at("quantity")),
          boost::json::value_to<double>(object.at("unit_price"))};
}

}  // namespace example::model::types
