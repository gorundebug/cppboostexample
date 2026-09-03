#include "orderservice/internal/app/service.hpp"

namespace example::order_service::app {

void Service::customMakersInit(servicelib::Context context) {
  (void)context;
  // Add only explicit user overrides here. Generated defaults stay in the
  // generated service and may change freely when the graph is regenerated.
}

void Service::customFunctionsInit(servicelib::Context context) {
  (void)context;
  // Add only explicit post-construction customization here.
}
void Service::serviceInit() {}
void Service::serviceStarted() {}
void Service::serviceStopping() noexcept {}

}  // namespace example::order_service::app