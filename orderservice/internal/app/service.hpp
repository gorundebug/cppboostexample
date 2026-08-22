#pragma once

#include "orderservice/internal/app/service.generated.hpp"

namespace example::order_service::app {

// User-owned extension point. The generator never overwrites this file.
class Service final : public ServiceGenerated {
 public:
  using ServiceGenerated::ServiceGenerated;
  ~Service() override = default;

 protected:
  void customMakersInit() override;
  void customFunctionsInit() override;
  void serviceInit() override;
  void serviceStarted() override;
  void serviceStopping() noexcept override;
};

}  // namespace example::order_service::app