#pragma once

#include <stdexcept>
#include <string>

#include <servicelib/runtime/serde/serde.hpp>
#include <model_cpp/include/example/model/types/order_processed.hpp>

namespace example::model::types::serde {

class OrderProcessedSerde final
    : public servicelib::serde::Serde<example::model::types::OrderProcessed> {
 public:
  bool IsStub() const noexcept override { return false; }

  servicelib::serde::SerdeData Serialize(
      const example::model::types::OrderProcessed& value) const override {
    servicelib::serde::SerdeData result;
    SerializeTo(result, value);
    return result;
  }
  void SerializeTo(servicelib::serde::SerdeData& output,
                   const example::model::types::OrderProcessed& value) const override {
    const auto text = boost::json::serialize(boost::json::value_from(value));
    const auto* bytes = reinterpret_cast<const std::byte*>(text.data());
    output.insert(output.end(), bytes, bytes + text.size());
  }
  example::model::types::OrderProcessed Deserialize(
      servicelib::serde::SerdeView data) const override {
    const auto* chars = reinterpret_cast<const char*>(data.data());
    return boost::json::value_to<example::model::types::OrderProcessed>(
        boost::json::parse(std::string{chars, data.size()}));
  }
};

}  // namespace example::model::types::serde
