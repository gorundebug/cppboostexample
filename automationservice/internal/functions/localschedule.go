package functions

import (
	"context"

	"github.com/gorundebug/servicelib/datasource"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ runtime.ScheduleEndpointFunction[runtime.ScheduleTrigger] = (*LocalSchedule)(nil)

func MakeEndpointConsumerLocalSchedule[R, E any](
	stream runtime.TypedInputStream[runtime.ScheduleTrigger, R, E],
	function runtime.ScheduleEndpointFunction[runtime.ScheduleTrigger],
) (runtime.Consumer[runtime.ScheduleTrigger], error) {
	return datasource.GocronEndpointConsumer(stream, function)
}

// LocalSchedule converts a scheduler trigger into zero or more values for the
// existing typed input stream.
type LocalSchedule struct{}

func (f *LocalSchedule) OnTrigger(
	ctx context.Context,
	trigger runtime.ScheduleTrigger,
	out runtime.Collect[runtime.ScheduleTrigger],
) {
	out.Out(ctx, trigger)
}

// MakeLocalSchedule constructs the endpoint function once during service startup.
func MakeLocalSchedule(
	_ context.Context,
	_ environment.ServiceEnvironment,
	_ *runtimecfg.CronEndpointConfig,
) (*LocalSchedule, error) {
	return &LocalSchedule{}, nil
}
