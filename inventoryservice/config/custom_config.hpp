#pragma once

#include <yaml-cpp/yaml.h>

namespace example::inventory_service::config {

// User-owned typed extension point. Add service-specific fields here.
struct CustomConfig final {};

// Apply custom YAML fields from the same document as generated topology
// sections. This file is preserved during regeneration.
inline void ApplyConfig(const YAML::Node&, CustomConfig&) {}

// Apply service-specific environment variables after YAML overrides.
inline void ApplyEnvironment(CustomConfig&) {}

}  // namespace example::inventory_service::config