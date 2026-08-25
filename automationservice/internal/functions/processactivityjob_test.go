package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/require"
)

// Record Activity progress with DurableCallHeartbeat and return the processed job result.

func TestProcessActivityJob_Map(t *testing.T) {
	f := &ProcessActivityJob{}
	var collected []string
	var heartbeats []any
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	durable := runtime.NewDurableCallContext("activity-1", func(_ context.Context, value any) error {
		heartbeats = append(heartbeats, value)
		return nil
	}, nil)
	ctx := runtime.WithDurableCallContext(context.Background(), durable)

	f.Map(ctx, nil, "job-1", out)

	require.Equal(t, []any{"processing:job-1"}, heartbeats)
	require.Equal(t, []string{"activity:processed:job-1"}, collected)
}
