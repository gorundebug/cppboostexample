#include "orderservice/internal/app/service.hpp"

namespace example::order_service::app {

void Service::customMakersInit() {
  // Replace generated makers here. This file is never overwritten.
  // makers_.map_order_item_result_to_order_state = custom_map_order_item_result_to_order_state_maker;
  // makers_.map_to_order_processed = custom_map_to_order_processed_maker;
  // makers_.map_to_order_state = custom_map_to_order_state_maker;
  // makers_.order_processed_endpoint = custom_order_processed_endpoint_maker;
  // makers_.process_order = custom_process_order_maker;
  // makers_.process_order_item = custom_process_order_item_maker;
  // makers_.process_order_items = custom_process_order_items_maker;
  // makers_.soft_deadline = custom_soft_deadline_maker;
}
void Service::customFunctionsInit() {
  // Configure constructed functions here before the graph is wired.
  // functions_.map_order_item_result_to_order_state->configure(...);
  // functions_.map_to_order_processed->configure(...);
  // functions_.map_to_order_state->configure(...);
  // functions_.order_processed_endpoint->configure(...);
  // functions_.process_order->configure(...);
  // functions_.process_order_item->configure(...);
  // functions_.process_order_items->configure(...);
  // functions_.soft_deadline->configure(...);
}
void Service::serviceInit() {}
void Service::serviceStarted() {}
void Service::serviceStopping() noexcept {}

}  // namespace example::order_service::app
