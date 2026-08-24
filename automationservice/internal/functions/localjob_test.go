package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

// Create a job message identifying the local scheduled firing.

func TestLocalJob_Map(t *testing.T) {
	f := &LocalJob{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	value := runtime.ScheduleTrigger{ScheduleID: "local-cleanup", TriggerID: "trigger-1"}
	f.Map(context.Background(), nil, value, out)
	assert.Equal(t, []string{"local:local-cleanup:trigger-1"}, collected)
}
