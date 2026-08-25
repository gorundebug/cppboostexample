package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

func TestTemporalScheduleOnTrigger(t *testing.T) {
	function := &TemporalSchedule{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, value string) { collected = append(collected, value) })
	function.OnTrigger(context.Background(), runtime.ScheduleTrigger{ScheduleID: "durable-report", TriggerID: "trigger-2"}, out)
	assert.Equal(t, []string{"temporal:durable-report:trigger-2"}, collected)
}
