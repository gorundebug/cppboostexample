#pragma once

#include <boost/json.hpp>

#include <string>
#include <vector>

#include <model/include/example/model/types/order_item.hpp>

namespace example::order_service::types {

struct Order final {
  std::string id;
  std::string customer_id;
  std::vector<example::model::types::OrderItem> items;
  double total_amount{0.0};
  std::string created_at;
  std::string trace_id;
};

inline void tag_invoke(boost::json::value_from_tag, boost::json::value& json,
                       const Order& value) {
  json = {{"id", value.id},
          {"customer_id", value.customer_id},
          {"items", boost::json::value_from(value.items)},
          {"total_amount", value.total_amount},
          {"created_at", value.created_at},
          {"trace_id", value.trace_id}};
}

inline Order tag_invoke(boost::json::value_to_tag<Order>,
                        const boost::json::value& json) {
  const auto& object = json.as_object();
  return {boost::json::value_to<std::string>(object.at("id")),
          boost::json::value_to<std::string>(object.at("customer_id")),
          boost::json::value_to<std::vector<example::model::types::OrderItem>>(
              object.at("items")),
          boost::json::value_to<double>(object.at("total_amount")),
          boost::json::value_to<std::string>(object.at("created_at")),
          boost::json::value_to<std::string>(object.at("trace_id"))};
}

}  // namespace example::order_service::types
