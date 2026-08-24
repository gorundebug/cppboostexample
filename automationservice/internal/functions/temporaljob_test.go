package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

// Create a job message identifying the durable scheduled firing.

func TestTemporalJob_Map(t *testing.T) {
	f := &TemporalJob{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	value := runtime.ScheduleTrigger{ScheduleID: "durable-report", TriggerID: "trigger-2"}
	f.Map(context.Background(), nil, value, out)
	assert.Equal(t, []string{"temporal:durable-report:trigger-2"}, collected)
}
