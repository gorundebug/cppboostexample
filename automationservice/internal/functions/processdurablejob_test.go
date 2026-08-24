package functions

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

// Process one accepted automation job and return its result.

func TestProcessDurableJob_Map(t *testing.T) {
	f := &ProcessDurableJob{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	f.Map(context.Background(), nil, "job-42", out)
	assert.Equal(t, []string{"processed:job-42"}, collected)
}
