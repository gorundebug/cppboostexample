#pragma once

#include <stdexcept>
#include <string>
#include <boost/json.hpp>

#include <servicelib/runtime/serde/serde.hpp>
#include <analyticsservice/internal/types/analytics_key.hpp>

namespace example::analytics_service::types::serde {

class AnalyticsKeySerde final
    : public servicelib::serde::Serde<example::analytics_service::types::AnalyticsKey> {
 public:
  bool IsStub() const noexcept override { return false; }

  servicelib::serde::SerdeData Serialize(
      const example::analytics_service::types::AnalyticsKey& value) const override {
    servicelib::serde::SerdeData output;
    SerializeTo(output, value);
    return output;
  }
  void SerializeTo(servicelib::serde::SerdeData& output,
                   const example::analytics_service::types::AnalyticsKey& value) const override {
    const auto text = boost::json::serialize(boost::json::value_from(value));
    const auto* bytes = reinterpret_cast<const std::byte*>(text.data());
    output.insert(output.end(), bytes, bytes + text.size());
  }
  example::analytics_service::types::AnalyticsKey Deserialize(
      servicelib::serde::SerdeView input) const override {
    const auto* chars = reinterpret_cast<const char*>(input.data());
    return boost::json::value_to<example::analytics_service::types::AnalyticsKey>(
        boost::json::parse(std::string_view(chars, input.size())));
  }
};

}  // namespace example::analytics_service::types::serde