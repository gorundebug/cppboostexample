#include "inventoryservice/internal/app/service.hpp"

namespace example::inventory_service::app {

void Service::customMakersInit() {
  // Replace generated makers here. This file is never overwritten.
  // makers_.get_inventory_item_data = custom_get_inventory_item_data_maker;
  // makers_.process_order_item = custom_process_order_item_maker;
}
void Service::customFunctionsInit() {
  // Configure constructed functions here before the graph is wired.
  // functions_.get_inventory_item_data->configure(...);
  // functions_.process_order_item->configure(...);
}
void Service::serviceInit() {}
void Service::serviceStarted() {}
void Service::serviceStopping() noexcept {}

}  // namespace example::inventory_service::app
