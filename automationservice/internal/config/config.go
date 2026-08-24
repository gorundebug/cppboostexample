package config

// CustomConfig holds service-specific configuration fields.
// Add your own fields here; they are read from the same YAML level
// as the generated config sections (services, streams, dataConnectors, etc.).
//
// Example:
//
//	type CustomConfig struct {
//	    Database DatabaseConfig `yaml:"database" mapstructure:"database"`
//	}
//
// This file is generated once and never overwritten on regeneration.
type CustomConfig struct {
}
