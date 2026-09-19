#include <concepts>

#include <gtest/gtest.h>

#include "inventoryservice/internal/functions/inventory_item/get_inventory_item_error.hpp"

namespace example::inventory_service::functions {

TEST(GetInventoryItemError, Contract) {
  static_assert(std::default_initializable<GetInventoryItemError>);
  GTEST_SKIP() << "TODO: add behavior assertions for GetInventoryItemError";
}

}  // namespace example::inventory_service::functions