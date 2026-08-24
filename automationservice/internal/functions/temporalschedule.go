package functions

import (
	"context"

	"github.com/gorundebug/servicelib/datasource"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ runtime.ScheduleEndpointFunction[runtime.ScheduleTrigger] = (*TemporalSchedule)(nil)

func MakeEndpointConsumerTemporalSchedule[R, E any](
	stream runtime.TypedInputStream[runtime.ScheduleTrigger, R, E],
	function runtime.ScheduleEndpointFunction[runtime.ScheduleTrigger],
) (runtime.Consumer[runtime.ScheduleTrigger], error) {
	return datasource.TemporalScheduleEndpointConsumer(stream, function)
}

// TemporalSchedule converts a scheduler trigger into zero or more values for the
// existing typed input stream.
type TemporalSchedule struct{}

func (f *TemporalSchedule) OnTrigger(
	ctx context.Context,
	trigger runtime.ScheduleTrigger,
	out runtime.Collect[runtime.ScheduleTrigger],
) {
	out.Out(ctx, trigger)
}

// MakeTemporalSchedule constructs the endpoint function once during service startup.
func MakeTemporalSchedule(
	_ context.Context,
	_ environment.ServiceEnvironment,
	_ *runtimecfg.TemporalEndpointConfig,
) (*TemporalSchedule, error) {
	return &TemporalSchedule{}, nil
}
