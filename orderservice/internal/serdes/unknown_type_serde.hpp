#pragma once

#include <stdexcept>
#include <string>
#include <boost/json.hpp>

#include <servicelib/runtime/serde/serde.hpp>
#include <orderservice/internal/types/unknown_type.hpp>

namespace example::order_service::types::serde {

class UnknownTypeSerde final
    : public servicelib::serde::Serde<example::order_service::types::UnknownType> {
 public:
  bool IsStub() const noexcept override { return false; }

  servicelib::serde::SerdeData Serialize(
      const example::order_service::types::UnknownType& value) const override {
    servicelib::serde::SerdeData output;
    SerializeTo(output, value);
    return output;
  }
  void SerializeTo(servicelib::serde::SerdeData& output,
                   const example::order_service::types::UnknownType& value) const override {
    const auto text = boost::json::serialize(boost::json::value_from(value));
    const auto* bytes = reinterpret_cast<const std::byte*>(text.data());
    output.insert(output.end(), bytes, bytes + text.size());
  }
  example::order_service::types::UnknownType Deserialize(
      servicelib::serde::SerdeView input) const override {
    const auto* chars = reinterpret_cast<const char*>(input.data());
    return boost::json::value_to<example::order_service::types::UnknownType>(
        boost::json::parse(std::string_view(chars, input.size())));
  }
};

}  // namespace example::order_service::types::serde