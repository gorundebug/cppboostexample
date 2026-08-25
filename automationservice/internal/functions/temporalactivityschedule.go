package functions

import (
	"context"
	"fmt"

	"github.com/gorundebug/servicelib/datasource"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ runtime.ScheduleEndpointFunction[string] = (*TemporalActivitySchedule)(nil)

func MakeEndpointConsumerTemporalActivitySchedule[T, R, E any](
	stream runtime.TypedInputStream[T, R, E],
	function runtime.ScheduleEndpointFunction[T],
) (runtime.Consumer[T], error) {
	return datasource.TemporalScheduleEndpointConsumer(stream, function)
}

// TemporalActivitySchedule converts a scheduler trigger into zero or more values for the
// existing typed input stream.
type TemporalActivitySchedule struct{}

// // Create an Activity job message identifying the durable scheduled firing.
func (f *TemporalActivitySchedule) OnTrigger(
	ctx context.Context,
	trigger runtime.ScheduleTrigger,
	out runtime.Collect[string],
) {
	out.Out(ctx, fmt.Sprintf("scheduled-activity:%s:%s", trigger.ScheduleID, trigger.TriggerID))
}

// MakeTemporalActivitySchedule constructs the endpoint function once during service startup.
func MakeTemporalActivitySchedule(
	_ context.Context,
	_ environment.ServiceEnvironment,
	_ *runtimecfg.TemporalEndpointConfig,
) (*TemporalActivitySchedule, error) {
	return &TemporalActivitySchedule{}, nil
}
