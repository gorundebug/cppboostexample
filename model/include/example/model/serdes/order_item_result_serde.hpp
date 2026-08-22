#pragma once

#include <boost/json.hpp>

#include <cstddef>
#include <string>

#include <servicelib/runtime/serde/serde.hpp>
#include <model/include/example/model/types/order_item_result.hpp>

namespace example::model::types::serde {

class OrderItemResultSerde final
    : public servicelib::serde::Serde<example::model::types::OrderItemResult> {
 public:
  bool IsStub() const noexcept override { return false; }

  servicelib::serde::SerdeData Serialize(
      const example::model::types::OrderItemResult& value) const override {
    servicelib::serde::SerdeData result;
    SerializeTo(result, value);
    return result;
  }
  void SerializeTo(servicelib::serde::SerdeData& output,
                   const example::model::types::OrderItemResult& value) const override {
    const auto text = boost::json::serialize(boost::json::value_from(value));
    const auto* bytes = reinterpret_cast<const std::byte*>(text.data());
    output.insert(output.end(), bytes, bytes + text.size());
  }
  example::model::types::OrderItemResult Deserialize(
      servicelib::serde::SerdeView data) const override {
    const auto* chars = reinterpret_cast<const char*>(data.data());
    return boost::json::value_to<example::model::types::OrderItemResult>(
        boost::json::parse(std::string{chars, data.size()}));
  }
};

}  // namespace example::model::types::serde
