#include "analyticsservice/internal/app/service.hpp"

namespace example::analytics_service::app {

void Service::customMakersInit() {
  // Replace generated makers here. This file is never overwritten.
}
void Service::customFunctionsInit() {
  // Configure constructed functions here before the graph is wired.
}
void Service::serviceInit() {}
void Service::serviceStarted() {}
void Service::serviceStopping() noexcept {}

}  // namespace example::analytics_service::app
