package activity

import (
	"context"
	"fmt"

	"github.com/gorundebug/servicelib/datasource"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ runtime.ScheduleEndpointFunction[string] = (*TemporalActivityScheduleSource)(nil)

func MakeEndpointConsumerTemporalActivityScheduleSource[T, R, E any](
	stream runtime.TypedInputStream[T, R, E],
	function runtime.ScheduleEndpointFunction[T],
) (runtime.Consumer[T], error) {
	return datasource.TemporalScheduleEndpointConsumer(stream, function)
}

// TemporalActivityScheduleSource converts a scheduler trigger into zero or more values for the
// existing typed input stream.
type TemporalActivityScheduleSource struct{}

// // Create an Activity job message identifying the durable scheduled firing.
func (f *TemporalActivityScheduleSource) OnTrigger(
	ctx context.Context,
	trigger runtime.ScheduleTrigger,
	out runtime.Collect[string],
) {
	_ = runtime.DurableCallHeartbeat(ctx, "scheduled:"+trigger.TriggerID)
	out.Out(ctx, fmt.Sprintf("scheduled-activity:%s:%s", trigger.ScheduleID, trigger.TriggerID))
}

// MakeTemporalActivityScheduleSource constructs the endpoint function once during service startup.
func MakeTemporalActivityScheduleSource(
	_ context.Context,
	_ environment.ServiceEnvironment,
	_ *runtimecfg.TemporalEndpointConfig,
) (*TemporalActivityScheduleSource, error) {
	return &TemporalActivityScheduleSource{}, nil
}
