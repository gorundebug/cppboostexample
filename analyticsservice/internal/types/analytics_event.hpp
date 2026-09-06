#pragma once

#include <boost/json.hpp>

#include <cstddef>
#include <cstdint>
#include <string>
#include <unordered_map>
#include <vector>

namespace example::analytics_service::types {

struct AnalyticsEvent final {
  std::string key;
  std::int64_t value{0};
  std::string kind;
};

inline void tag_invoke(boost::json::value_from_tag, boost::json::value& json,
                       const AnalyticsEvent& value) {
  json = {{"key", value.key}, {"value", value.value}, {"kind", value.kind}};
}

inline AnalyticsEvent tag_invoke(boost::json::value_to_tag<AnalyticsEvent>,
                                 const boost::json::value& json) {
  const auto& object = json.as_object();
  return {boost::json::value_to<std::string>(object.at("key")),
          boost::json::value_to<std::int64_t>(object.at("value")),
          boost::json::value_to<std::string>(object.at("kind"))};
}

}  // namespace example::analytics_service::types
