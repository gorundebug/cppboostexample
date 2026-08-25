package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

// Return the visible result of one scheduled Activity execution.

func TestProcessScheduledActivity_Map(t *testing.T) {
	f := &ProcessScheduledActivity{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	f.Map(context.Background(), nil, "scheduled-activity:schedule-1:trigger-1", out)
	assert.Equal(t, []string{"activity:processed:scheduled-activity:schedule-1:trigger-1"}, collected)
}
