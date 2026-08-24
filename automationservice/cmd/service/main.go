package main

import (
	"context"
	"flag"
	"log"
	"os"

	automationservice "github.com/gorundebug/cppboostexample-automationservice/internal/app"
)

var (
	build_version = "v0.0.0" //nolint:gochecknoglobals
	build_commit  = ""       //nolint:gochecknoglobals
)

func main() {
	valuesPathArg := flag.String("values", "./config/overrides.yaml", "service config values path")
	configPathArg := flag.String("config", "./config/config.yaml", "service config path")
	flag.Parse()

	if err := automationservice.Start(
		context.Background(),
		nil,
		nil,
		configPathArg,
		valuesPathArg,
		build_version,
		build_commit,
	); err != nil {
		log.Printf("start service error: %s", err.Error())
		os.Exit(1)
	}
	os.Exit(0)
}
