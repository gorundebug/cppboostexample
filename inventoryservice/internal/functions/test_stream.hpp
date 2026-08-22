#pragma once

#include <servicelib/runtime/base.hpp>

namespace example::inventory_service::functions::test {

class Stream final : public servicelib::StreamBase {
 public:
  ~Stream() override = default;

 private:
  size_t buildTopology(servicelib::StreamBuilderContext&, size_t id,
                       std::vector<size_t>*, bool) override {
    return id;
  }

  void verifyTopology(servicelib::StreamVerifyContext&) const override {}

  void printTopology(servicelib::TopologyPrinter&,
                     std::unordered_set<size_t>&) const override {}
};

}  // namespace example::inventory_service::functions::test
