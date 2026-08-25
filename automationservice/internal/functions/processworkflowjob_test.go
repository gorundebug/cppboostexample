package functions

import (
	"context"
	"testing"
	"time"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/require"
)

// Continue the Workflow as new once, then return its final result.

func TestProcessWorkflowJob_Map(t *testing.T) {
	f := &ProcessWorkflowJob{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	durable := runtime.NewDurableWorkflowContext("workflow-1", func(_ time.Duration) error { return nil }, nil)
	ctx := runtime.WithDurableCallContext(context.Background(), durable)

	var panicValue any
	func() {
		defer func() { panicValue = recover() }()
		f.Map(ctx, nil, "job-1", out)
	}()
	request, ok := panicValue.(*runtime.TemporalContinueAsNewRequest)
	require.True(t, ok)
	require.Equal(t, "continued:job-1", request.NextInput)
	require.Empty(t, collected)

	f.Map(ctx, nil, "sequential:b:sequential:a:continued:job-1", out)
	require.Equal(t, []string{"workflow:processed:sequential:b:sequential:a:job-1"}, collected)
}
