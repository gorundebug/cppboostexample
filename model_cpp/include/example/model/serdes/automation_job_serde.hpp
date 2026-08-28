#pragma once

#include <stdexcept>
#include <string>
#include <boost/json.hpp>

#include <servicelib/runtime/serde/serde.hpp>
#include <model_cpp/include/example/model/types/automation_job.hpp>

namespace example::model::types::serde {

class AutomationJobSerde final
    : public servicelib::serde::Serde<example::model::types::AutomationJob> {
 public:
  bool IsStub() const noexcept override { return false; }

  servicelib::serde::SerdeData Serialize(
      const example::model::types::AutomationJob& value) const override {
    servicelib::serde::SerdeData output;
    SerializeTo(output, value);
    return output;
  }
  void SerializeTo(servicelib::serde::SerdeData& output,
                   const example::model::types::AutomationJob& value) const override {
    const auto text = boost::json::serialize(boost::json::value_from(value));
    const auto* bytes = reinterpret_cast<const std::byte*>(text.data());
    output.insert(output.end(), bytes, bytes + text.size());
  }
  example::model::types::AutomationJob Deserialize(
      servicelib::serde::SerdeView input) const override {
    const auto* chars = reinterpret_cast<const char*>(input.data());
    return boost::json::value_to<example::model::types::AutomationJob>(
        boost::json::parse(std::string_view(chars, input.size())));
  }
};

}  // namespace example::model::types::serde