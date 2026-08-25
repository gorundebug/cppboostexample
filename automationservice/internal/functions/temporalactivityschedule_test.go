package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/require"
)

func TestTemporalActivityScheduleOnTrigger(t *testing.T) {
	function := &TemporalActivitySchedule{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, value string) {
		collected = append(collected, value)
	})
	trigger := runtime.ScheduleTrigger{ScheduleID: "activity-schedule", TriggerID: "trigger-1"}

	function.OnTrigger(context.Background(), trigger, out)

	require.Equal(t, []string{"scheduled-activity:activity-schedule:trigger-1"}, collected)
}
