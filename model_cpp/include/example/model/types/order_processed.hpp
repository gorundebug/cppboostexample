#pragma once

#include <boost/json.hpp>

#include <cstddef>
#include <string>

namespace example::model::types {

struct OrderProcessed final {
  std::string order_id;
  std::string status;
  std::string processed_at;
  std::size_t total_items{};
  std::size_t confirmed_items{};
  std::string failure_reason;
};

inline void tag_invoke(boost::json::value_from_tag, boost::json::value& json,
                       const OrderProcessed& value) {
  json = {{"order_id", value.order_id}, {"status", value.status},
          {"processed_at", value.processed_at}, {"total_items", value.total_items},
          {"confirmed_items", value.confirmed_items},
          {"failure_reason", value.failure_reason}};
}

inline OrderProcessed tag_invoke(boost::json::value_to_tag<OrderProcessed>,
                                 const boost::json::value& json) {
  const auto& object = json.as_object();
  return {boost::json::value_to<std::string>(object.at("order_id")),
          boost::json::value_to<std::string>(object.at("status")),
          boost::json::value_to<std::string>(object.at("processed_at")),
          boost::json::value_to<std::size_t>(object.at("total_items")),
          boost::json::value_to<std::size_t>(object.at("confirmed_items")),
          boost::json::value_to<std::string>(object.at("failure_reason"))};
}

}  // namespace example::model::types
