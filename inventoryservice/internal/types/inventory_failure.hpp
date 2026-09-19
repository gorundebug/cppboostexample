#pragma once

#include <any>
#include <cstddef>
#include <cstdint>
#include <exception>
#include <string>
#include <unordered_map>
#include <vector>


namespace example::inventory_service::types {

using InventoryFailure = std::exception_ptr;

}  // namespace example::inventory_service::types