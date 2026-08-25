package functions

import (
	"context"
	"fmt"

	"github.com/gorundebug/servicelib/datasource"
	"github.com/gorundebug/servicelib/runtime"
	runtimecfg "github.com/gorundebug/servicelib/runtime/config"
	"github.com/gorundebug/servicelib/runtime/environment"
)

var _ runtime.ScheduleEndpointFunction[string] = (*TemporalSchedule)(nil)

func MakeEndpointConsumerTemporalSchedule[T, R, E any](
	stream runtime.TypedInputStream[T, R, E],
	function runtime.ScheduleEndpointFunction[T],
) (runtime.Consumer[T], error) {
	return datasource.TemporalScheduleEndpointConsumer(stream, function)
}

// TemporalSchedule converts a scheduler trigger into zero or more values for the
// existing typed input stream.
type TemporalSchedule struct{}

func (f *TemporalSchedule) OnTrigger(
	ctx context.Context,
	trigger runtime.ScheduleTrigger,
	out runtime.Collect[string],
) {
	out.Out(ctx, fmt.Sprintf("temporal:%s:%s", trigger.ScheduleID, trigger.TriggerID))
}

// MakeTemporalSchedule constructs the endpoint function once during service startup.
func MakeTemporalSchedule(
	_ context.Context,
	_ environment.ServiceEnvironment,
	_ *runtimecfg.TemporalEndpointConfig,
) (*TemporalSchedule, error) {
	return &TemporalSchedule{}, nil
}
