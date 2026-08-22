#pragma once

#include <boost/json.hpp>

#include <cstddef>
#include <string>

#include <servicelib/runtime/serde/serde.hpp>
#include <orderservice/internal/types/order.hpp>

namespace example::order_service::types::serde {

class OrderSerde final
    : public servicelib::serde::Serde<example::order_service::types::Order> {
 public:
  bool IsStub() const noexcept override { return false; }

  servicelib::serde::SerdeData Serialize(
      const example::order_service::types::Order& value) const override {
    servicelib::serde::SerdeData result;
    SerializeTo(result, value);
    return result;
  }
  void SerializeTo(servicelib::serde::SerdeData& output,
                   const example::order_service::types::Order& value) const override {
    const auto text = boost::json::serialize(boost::json::value_from(value));
    const auto* bytes = reinterpret_cast<const std::byte*>(text.data());
    output.insert(output.end(), bytes, bytes + text.size());
  }
  example::order_service::types::Order Deserialize(
      servicelib::serde::SerdeView data) const override {
    const auto* chars = reinterpret_cast<const char*>(data.data());
    return boost::json::value_to<example::order_service::types::Order>(
        boost::json::parse(std::string{chars, data.size()}));
  }
};

}  // namespace example::order_service::types::serde
