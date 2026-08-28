#pragma once

#include <boost/json.hpp>

#include <string>
#include <vector>

#include <model_cpp/include/example/model/types/order_item_result.hpp>

namespace example::order_service::types {

struct OrderState final {
  std::string order_id;
  std::string status;
  std::vector<example::model::types::OrderItemResult> confirmed_items;
  double total_amount{0.0};
  std::string processed_at;
};

inline void tag_invoke(boost::json::value_from_tag, boost::json::value& json,
                       const OrderState& value) {
  json = {{"order_id", value.order_id},
          {"status", value.status},
          {"confirmed_items", boost::json::value_from(value.confirmed_items)},
          {"total_amount", value.total_amount},
          {"processed_at", value.processed_at}};
}

inline OrderState tag_invoke(boost::json::value_to_tag<OrderState>,
                             const boost::json::value& json) {
  const auto& object = json.as_object();
  return {boost::json::value_to<std::string>(object.at("order_id")),
          boost::json::value_to<std::string>(object.at("status")),
          boost::json::value_to<
              std::vector<example::model::types::OrderItemResult>>(
              object.at("confirmed_items")),
          boost::json::value_to<double>(object.at("total_amount")),
          boost::json::value_to<std::string>(object.at("processed_at"))};
}

}  // namespace example::order_service::types
