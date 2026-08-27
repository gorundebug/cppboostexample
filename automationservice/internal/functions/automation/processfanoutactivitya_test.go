package automation

import (
	"context"
	"testing"

	"github.com/gorundebug/servicelib/runtime"
	"github.com/stretchr/testify/assert"
)

// Return Activity A's typed result before the Workflow Split.

func TestProcessFanoutActivityA_Map(t *testing.T) {
	t.Skip("not yet implemented") // TODO: remove when implementation is ready
	f := &ProcessFanoutActivityA{}
	var collected []string
	out := runtime.CollectFunc[string](func(_ context.Context, v string) {
		collected = append(collected, v)
	})
	var value string
	// TODO: populate value with meaningful test data
	f.Map(context.Background(), nil, value, out)
	assert.NotEmpty(t, collected)
}
