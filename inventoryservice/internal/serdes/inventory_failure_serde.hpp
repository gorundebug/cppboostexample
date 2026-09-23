#pragma once

#include <servicelib/runtime/serde/serde.hpp>
#include <inventoryservice/internal/types/inventory_failure.hpp>

namespace example::inventory_service::types::serde {
// This business outcome only crosses typed in-process links.
using InventoryFailureSerde = servicelib::serde::StubSerde<InventoryFailure>;
}  // namespace example::inventory_service::types::serde
