#include "analyticsservice/internal/app/service.hpp"

namespace example::analytics_service::app {

void Service::customMakersInit() {
  // Replace generated makers here. This file is never overwritten.
  // makers_.count_order_processed = custom_count_order_processed_maker;
  // makers_.order_processed_endpoint = custom_order_processed_endpoint_maker;
}
void Service::customFunctionsInit() {
  // Configure constructed functions here before the graph is wired.
  // functions_.count_order_processed->configure(...);
  // functions_.order_processed_endpoint->configure(...);
}
void Service::serviceInit() {}
void Service::serviceStarted() {}
void Service::serviceStopping() noexcept {}

}  // namespace example::analytics_service::app
