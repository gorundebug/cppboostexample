package cron

import (
	"context"

	"github.com/gorundebug/servicelib/datasource"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ runtime.ScheduleEndpointFunction[string] = (*LocalScheduleSource)(nil)

func MakeEndpointConsumerLocalScheduleSource[T, R, E any](
	stream runtime.TypedInputStream[T, R, E],
	function runtime.ScheduleEndpointFunction[T],
) (runtime.Consumer[T], error) {
	return datasource.GocronEndpointConsumer(stream, function)
}

// LocalScheduleSource converts a scheduler trigger into zero or more values for the
// existing typed input stream.
type LocalScheduleSource struct{}

// // Create a job message identifying the local scheduled firing.
func (f *LocalScheduleSource) OnTrigger(
	ctx context.Context,
	trigger runtime.ScheduleTrigger,
	out runtime.Collect[string],
) {
	// TODO: convert trigger to the input payload and emit it with out.Out.
	_ = ctx
	_ = trigger
	_ = out
}

// MakeLocalScheduleSource constructs the endpoint function once during service startup.
func MakeLocalScheduleSource(
	_ context.Context,
	_ environment.ServiceEnvironment,
	_ *runtimecfg.CronEndpointConfig,
) (*LocalScheduleSource, error) {
	return &LocalScheduleSource{}, nil
}
