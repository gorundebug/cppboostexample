package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

func TestLocalScheduleOnTrigger(t *testing.T) {
	function := &LocalSchedule{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, value string) {
		collected = append(collected, value)
	})
	trigger := runtime.ScheduleTrigger{ScheduleID: "local-cleanup", TriggerID: "trigger-1"}

	function.OnTrigger(context.Background(), trigger, out)

	assert.Equal(t, []string{"local:local-cleanup:trigger-1"}, collected)
}
